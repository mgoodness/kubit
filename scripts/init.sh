#!/bin/bash
# Copyright 2017 Michael Goodness
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ASSETS_BUCKET_NAME=
EXTERNAL_DOMAIN=
KMS_KEY_ID=

APISERVER_SERVICE_IP="10.252.0.1"
AWS_REGION="us-east-1"
AWS_WILDCARD="*.ec2.internal"
CLUSTER_NAME="kubit"
HYPERKUBE_VERSION="v1.5.2_coreos.1"
INTERNAL_DOMAIN="kubit.local"

shopt -s nocasematch

function create_kubeconfig() {
  echo -e "Creating kubeconfig entry..."
  kubectl config set-cluster ${CLUSTER_NAME}.${EXTERNAL_DOMAIN} --server=https://"kubernetes.${CLUSTER_NAME}.${EXTERNAL_DOMAIN}" \
    --certificate-authority=pki/ca.pem --embed-certs=true

  kubectl config set-credentials ${CLUSTER_NAME}.${EXTERNAL_DOMAIN}-admin --client-certificate=pki/admin.pem \
    --client-key=pki/admin-key.pem --embed-certs=true

  kubectl config set-context ${CLUSTER_NAME}.${EXTERNAL_DOMAIN} --cluster=${CLUSTER_NAME}.${EXTERNAL_DOMAIN} \
    --user=${CLUSTER_NAME}.${EXTERNAL_DOMAIN}-admin
  echo -e "done.\n"
}

function create_pki() {
  if [[ ! -f "pki/names.json" ]]; then
    while [[ "${pki_correct}" != "y" ]]; do
      echo -n "Enter PKI country: "
      read country
      echo -n "Enter PKI locality: "
      read locality
      echo -n "Enter PKI organization: "
      read org
      echo -n "Enter PKI organizational unit: "
      read org_unit
      echo -n "Enter PKI state/province: "
      read state

      echo
      names="\"C\": \"${country}\", \"L\": \"${locality}\", \"O\": \"${org}\", \"OU\": \"${org_unit}\", \"ST\": \"${state}\""
      echo -e "${names}"
      echo -n "Is the above correct? "
      read -n 1 pki_correct
      echo -e "\n"
    done
    echo "[{${names}}]" > pki/names.json
  else
    echo -e "PKI subject already set. Edit pki/names.json manually.\n"
  fi

  ca_key_type=$(<pki/ca_key_type.json)
  names=$(<pki/names.json)
  pki_key_type=$(<pki/pki_key_type.json)
  if [[ ! -f pki/ca-key.pem ]] || [[ ! -f pki/ca.pem ]]; then
    echo "Creating CA key & certificate..."
    cfssl genkey -initca - <<EOF | cfssljson -bare pki/ca
{
  "CN": "kubit CA",
  "key": ${ca_key_type},
  "names": ${names}
}
EOF
    echo -e "done.\n"
  else
    echo -e "CA certificate & key already exist. Skipping creation.\n"
  fi

  if [[ ! -f pki/etcd-key.pem ]] || [[ ! -f pki/etcd.pem ]]; then
    echo "Creating etcd keys & certificates..."
    cfssl gencert -ca pki/ca.pem -ca-key pki/ca-key.pem -config=pki/config.json \
      -profile=node - <<EOF | cfssljson -bare pki/etcd
{
  "CN": "kubit etcd peer",
  "hosts": [
    "${AWS_WILDCARD}",
    "*.${CLUSTER_NAME}.${INTERNAL_DOMAIN}"
  ],
  "key": ${pki_key_type},
  "names": ${names}
}
EOF
    echo -e "done.\n"
  else
    echo -e "etcd certificate & key already exist. Skipping creation.\n"
  fi

  if [[ ! -f pki/apiserver-key.pem ]] || [[ ! -f pki/apiserver.pem ]]; then
    echo "Creating API server key & certificate..."
    cfssl gencert -ca pki/ca.pem -ca-key pki/ca-key.pem -config=pki/config.json \
      -profile=node - <<EOF | cfssljson -bare pki/apiserver
{
  "CN": "kubit API server",
  "hosts": [
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster.local",
    "kubernetes.${CLUSTER_NAME}.${EXTERNAL_DOMAIN}",
    "kubernetes.${CLUSTER_NAME}.${INTERNAL_DOMAIN}",
    "${APISERVER_SERVICE_IP}"
  ],
  "key": ${pki_key_type},
  "names": ${names}
}
EOF
    echo -e "done.\n"
  else
    echo -e "API server certificate & key already exist. Skipping creation.\n"
  fi

  if [[ ! -f pki/admin-key.pem ]] || [[ ! -f pki/admin.pem ]]; then
    echo "Creating admin key & certificate..."
    cfssl gencert -ca pki/ca.pem -ca-key pki/ca-key.pem -config=pki/config.json \
      -profile=admin - <<EOF | cfssljson -bare pki/admin
{
  "CN": "kubit admin",
  "key": ${pki_key_type},
  "names": ${names}
}
EOF
    echo -e "done.\n"
  else
    echo -e "Admin certificate & key already exist. Skipping creation.\n"
  fi
}

function create_ssh_keys() {
  echo "Creating SSH keys..."
  mkdir -p keys
  ssh-keygen -b 2048 -C "${CLUSTER_NAME} cluster key" -f keys/${CLUSTER_NAME}
  echo -e "done.\n"
}

function create_tfvars() {
  while [[ "${ASSETS_BUCKET_NAME}" == "" ]]; do
    echo -n "Enter assets bucket name: "
    read ASSETS_BUCKET_NAME
  done
  echo

  while [[ "${EXTERNAL_DOMAIN}" == "" ]]; do
    echo -n "Enter external domain name: "
    read EXTERNAL_DOMAIN
  done
  echo

  echo -n "Enter AWS region [${AWS_REGION}]: "
  read aws_region
  [[ "${aws_region}" != "" ]] && AWS_REGION="${aws_region}"
  [[ "${AWS_REGION}" != "us-east-1" ]] && AWS_WILDCARD="*.${aws_region}.compute.internal"
  echo

  echo -n "Enter cluster name [${CLUSTER_NAME}]: "
  read cluster_name
  [[ "${cluster_name}" != "" ]] && CLUSTER_NAME="${cluster_name}"
  echo

  echo -n "Enter internal domain name [${INTERNAL_DOMAIN}]: "
  read internal_domain
  [[ "${internal_domain}" != "" ]] && INTERNAL_DOMAIN="${internal_domain}"
  echo

  echo -n "Enter hyperkube version [${HYPERKUBE_VERSION}]: "
  read hyperkube_version
  [[ "${hyperkube_version}" != "" ]] && HYPERKUBE_VERSION="${hyperkube_version}"
  echo

  echo -n "Enter KMS key ID (ARN) [blank = AWS master key]: "
  read kms_key_id
  [[ "${kms_key_id}" != "" ]] && KMS_KEY_ID="${kms_key_id}"
  echo

  cat << EOF > terraform.tfvars
assets_bucket_name = "${ASSETS_BUCKET_NAME}"
aws_region = "${AWS_REGION}"
cluster = { name = "${CLUSTER_NAME}" }
domain_names = { external = "${EXTERNAL_DOMAIN}", internal = "${INTERNAL_DOMAIN}" }
hyperkube = { version = "${HYPERKUBE_VERSION}" }
kms_key_id = "${KMS_KEY_ID}"
EOF
}

function upload_assets() {
  OPTIONS="--sse=AES256"
  [[ ${KMS_KEY_ID} != "" ]] && OPTIONS="--sse=aws:kms --sse-kms-key-id=${KMS_KEY_ID}"

  echo "Creating assets bucket..."
  aws s3 mb s3://${ASSETS_BUCKET_NAME}
  echo -e "done.\n"

  echo "Uploading addon manifests..."
  aws s3 sync addons s3://${ASSETS_BUCKET_NAME}/${CLUSTER_NAME}/addons ${OPTIONS}
  echo -e "done.\n"

  echo "Uploading PKI assets..."
  aws s3 sync pki s3://${ASSETS_BUCKET_NAME}/${CLUSTER_NAME}/pki ${OPTIONS}
  echo -e "done.\n"
}

if [[ ! -f terraform.tfvars ]]; then
  create_tfvars
else
  echo -e "Kubit variables are already set. Edit terraform.tfvars manually.\n"
  ASSETS_BUCKET_NAME=$(sed -n 's/^assets_bucket_name\ =\ "\(.*\)"$/\1/p' terraform.tfvars)
  EXTERNAL_DOMAIN=$(sed -n 's/^domain_names\ =\ {\ external\ =\ "\(.*\)",.*$/\1/p' terraform.tfvars)
fi

if [[ ! -f keys/${CLUSTER_NAME} ]] || [[ ! -f keys/${CLUSTER_NAME}.pub ]]; then
  create_ssh_keys
else
  echo -e "SSH key pair already exists. Skipping creation.\n"
fi

create_pki
create_kubeconfig
upload_assets
