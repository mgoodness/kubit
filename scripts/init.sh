#!/bin/bash
ASSETS_BUCKET_NAME=
EXTERNAL_DOMAIN=

APISERVER_SERVICE_IP="10.252.0.1"
AWS_REGION="us-east-1"
AWS_WILDCARD="*.ec2.internal"
CLUSTER_NAME="kubit"
HYPERKUBE_VERSION="v1.5.1_coreos.0"
INTERNAL_DOMAIN="kubit.local"

shopt -s nocasematch

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
  fi

  if [[ ! -f pki/etcd-key.pem ]] || [[ ! -f pki/etcd.pem ]]; then
    echo "Creating etcd keys & certificates..."
    cfssl gencert -ca pki/ca.pem -ca-key pki/ca-key.pem -config=pki/config.json \
      -profile=node - <<EOF | cfssljson -bare pki/etcd
{
  "CN": "kubit etcd peer",
  "hosts": [
    "${AWS_WILDCARD}",
    "*.${INTERNAL_DOMAIN}"
  ],
  "key": ${pki_key_type},
  "names": ${names}
}
EOF
    echo -e "done.\n"
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
    "kubernetes.${EXTERNAL_DOMAIN}",
    "kubernetes.${INTERNAL_DOMAIN}",
    "${APISERVER_INTERNAL_ADDRESS}"
  ],
  "key": ${pki_key_type},
  "names": ${names}
}
EOF
    echo -e "done.\n"
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
  fi

  if [[ ! -f pki/worker-key.pem ]] || [[ ! -f pki/worker.pem ]]; then
    echo "Creating worker key & certificate..."
    cfssl gencert -ca pki/ca.pem -ca-key pki/ca-key.pem -config=pki/config.json \
      -profile=node - <<EOF | cfssljson -bare pki/worker
{
  "CN": "kubit worker",
  "hosts": [
    "${AWS_WILDCARD}"
  ],
  "key": ${pki_key_type},
  "names": ${names}
}
EOF
    echo -e "done.\n"
  fi

  echo "Uploading PKI assets..."
  aws s3 sync pki s3://${ASSETS_BUCKET_NAME}/pki
  echo -e "done.\n"
}

function create_ssh_keys() {
  echo "Creating SSH keys..."
  mkdir -p keys
  if [[ ! -f keys/${CLUSTER_NAME} ]] || [[ ! -f keys/${CLUSTER_NAME}.pub ]]; then
     ssh-keygen -b 2048 -C "${CLUSTER_NAME} cluster key" -f keys/${CLUSTER_NAME}
  fi
  echo -e "done.\n"
}

function create_tfvars() {
  cat << EOF > terraform.tfvars
assets_bucket_name = "${ASSETS_BUCKET_NAME}"
aws_region = "${AWS_REGION}"
cluster = { name = "${CLUSTER_NAME}" }
domain_names = { external = "${EXTERNAL_DOMAIN}", internal = "${INTERNAL_DOMAIN}" }
hyperkube = { version = "${HYPERKUBE_VERSION}" }
EOF
}

function template_kubeconfig() {
  echo "Creating kubeconfig..."
  kubectl config set-cluster ${CLUSTER_NAME} --server=https://"kubernetes.${EXTERNAL_DOMAIN}" \
    --certificate-authority=pki/ca.pem --embed-certs=true --kubeconfig=kubeconfig

  kubectl config set-credentials ${CLUSTER_NAME}-admin --client-certificate=pki/admin.pem \
    --client-key=pki/admin-key.pem --embed-certs=true --kubeconfig=kubeconfig

  kubectl config set-context ${CLUSTER_NAME} --cluster=${CLUSTER_NAME} \
    --user=${CLUSTER_NAME}-admin --kubeconfig=kubeconfig

  kubectl config use-context ${CLUSTER_NAME} --kubeconfig=kubeconfig
  echo -e "done.\n"
}

function upload_addons() {
  echo "Uploading addon manifests..."
  aws s3 sync addons s3://${ASSETS_BUCKET_NAME}/addons
  echo -e "done.\n"
}


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

echo
echo "Creating assets bucket..."
aws s3 mb s3://${ASSETS_BUCKET_NAME}
echo -e "done.\n"

create_ssh_keys
create_pki
create_tfvars
template_kubeconfig
upload_addons
