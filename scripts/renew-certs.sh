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

KMS_KEY_ID=

shopt -s nocasematch

function create_kubeconfig() {
  echo -e "Creating kubeconfig entry..."
  kubectl config set-cluster ${CLUSTER_NAME} --server=https://"kubernetes.${EXTERNAL_DOMAIN}" \
    --certificate-authority=pki/ca.pem --embed-certs=true

  kubectl config set-credentials ${CLUSTER_NAME}-admin --client-certificate=pki/admin.pem \
    --client-key=pki/admin-key.pem --embed-certs=true

  kubectl config set-context ${CLUSTER_NAME} --cluster=${CLUSTER_NAME} \
    --user=${CLUSTER_NAME}-admin
  echo -e "done.\n"
}

function renew_pki() {
  if [[ -f pki/etcd-key.pem ]] && [[ -f pki/etcd.csr ]]; then
    echo "Renewing etcd certificate..."
    cfssl sign -ca pki/ca.pem -ca-key pki/ca-key.pem -config pki/config.json \
      -csr pki/etcd.csr -profile node | cfssljson -bare pki/etcd
    echo -e "done.\n"
  else
    echo -e "etcd key or CSR missing. Skipping renewal.\n"
  fi

  if [[ -f pki/apiserver-key.pem ]] && [[ -f pki/apiserver.csr ]]; then
    echo "Renewing API server certificate..."
    cfssl sign -ca pki/ca.pem -ca-key pki/ca-key.pem -config pki/config.json \
      -csr pki/apiserver.csr -profile=node | cfssljson -bare pki/apiserver
    echo -e "done.\n"
  else
    echo -e "API server key or CSR missing. Skipping renewal.\n"
  fi

  if [[ -f pki/admin-key.pem ]] && [[ -f pki/admin.pem ]]; then
    echo "Renewing admin certificate..."
    cfssl sign -ca pki/ca.pem -ca-key pki/ca-key.pem -config pki/config.json \
      -csr pki/admin.csr -profile=admin | cfssljson -bare pki/admin
    echo -e "done.\n"
  else
    echo -e "Admin key or CSR missing. Skipping renewal.\n"
  fi
}

function upload_assets() {
  OPTIONS="--sse=AES256"
  [[ ${KMS_KEY_ID} != "" ]] && OPTIONS="--sse=aws:kms --sse-kms-key-id=${KMS_KEY_ID}"

  echo "Uploading PKI assets..."
  aws s3 sync pki s3://${ASSETS_BUCKET_NAME}/pki ${OPTIONS}
  echo -e "done.\n"
}

ASSETS_BUCKET_NAME=$(sed -n 's/^assets_bucket_name\ =\ "\(.*\)"$/\1/p' terraform.tfvars)
CLUSTER_NAME=$(sed -n 's/^cluster\ =\ {\ name\ =\ "\(.*\)"\ }$/\1/p' terraform.tfvars)
EXTERNAL_DOMAIN=$(sed -n 's/^domain_names\ =\ {\ external\ =\ "\(.*\)",.*$/\1/p' terraform.tfvars)
KMS_KEY_ID=$(sed -n 's/^kms_key_id\ =\ "\(.*\)"$/\1/p' terraform.tfvars)

renew_pki
create_kubeconfig
upload_assets
