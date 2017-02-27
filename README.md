# kubit

Kubernetes cluster provisioning for AWS using CoreOS and Terraform

This project is essentially a simplified & customized version of [kube-aws](https://github.com/coreos/kube-aws) from [CoreOS](https://coreos.com/) that uses Terraform instead of CloudFormation. **If you have no other preference between the two, I highly recommend using `kube-aws`.** Unlike this project, that one is run by people who know what they're doing.

## Dependencies
 - [Terraform v0.8.2+](https://www.terraform.io/)
 - [cfssl & cfssljson v1.2.0](https://cfssl.org/)

## TL;DR
 1. Run `scripts/init.sh`
 2. Run `terraform get --update`
 3. Run `terraform plan`
 4. Run `terraform apply`

## Initialization
`scripts/init.sh` will create an SSH key pair and all required TLS assets, generate a `kubeconfig` file, and set the required variables in `terraform.tfvars`. It will also create an S3 bucket (if the bucket does not already exist) and upload assets and manifests to it.

### Variables
After initialization, the user may override any of the `io.tf` variable defaults (listed below) by manually defining them in `terraform.tfvars`.

Name | Type | Description | Handled by `init.sh` | Default
--- | --- | --- | --- | ---
`assets_bucket_name` | string | S3 bucket in which to store addon manifests & SSL assets | no | **none**
`aws_region` | string | AWS region in which to create cluster | yes| `us-east-1`
`cluster.name` | string | name of cluster to create | yes | `kubit`
`cluster.pods_cidr_block` | string | CIDR block to use for Kubernetes pod network | no | `10.251.0.0/16`
`cluster.services_cidr_block` | string | CIDR block to use for Kubernetes services | no | `10.252.0.0/16`
`domain_names.external` | string | public Route53 zone to create | yes | **none**
`domain_names.internal` | string | private hosted Route53 zone to create | yes | `kubit.local`
`ebs_encrypted` | bool | if `true`, etcd data volume will be encrypted | no | `true`
`hyperkube.repository` | string | hyperkube container repository | no | `quay.io/coreos/hyperkube`
`hyperkube.version` | string | hyperkube container image | yes | `v1.5.3_coreos.0`
`kms_key_id` | string | if provided, key with which to encrypt cluster assets & etcd data volume | yes | none (AWS will create & use a default key)
`subnets.availability_zones` | list | AWS availability zones in which to create subnets | no | `["a","b","c"]`
`subnets.private_cidr_blocks` | list | CIDRs to use for private subnets | no | `["10.150.10.0/24","10.150.20.0/24","10.150.30.0/24"]`
`subnets.public_cidr_blocks` | list | CIDRs to use for public subnets | no | `["10.150.1.0/24","10.150.2.0/24","10.150.3.0/24"]`
`vpc_cidr_block` | string | CIDR block for VPC network | no | `10.150.0.0/16`

#### Caveats
 - Avoid changing any `init.sh`-handled variables except through that script. Altering them manually will invalidate any generated TLS assets.
 - Avoid changing `cluster.services_cidr_block` unless absolutely necessary. Doing so also requires changes to `scripts/init.sh` and `addons/kube-dns-svc.yaml`.

#### Encryption
If you have specified an account specific `kms_key_id` (ARN) perform the following steps *before deploying the cluster*.

 - Create cluster IAM Roles:

   ```
   terraform apply --target=module.iam
   ```

 - Grant generated cluster IAM Roles `Key Users` access to the specified KMS key:

   ```
   <cluster.name>-controllers
   <cluster.name>-etcd
   <cluster.name>-workers
   ```

## PKI Renewal
`scripts/renew-pki.sh` will renew the API server, etcd, and admin TLS certificates using the existing keys & CSRs. It will then update `kubeconfig` and upload the new certificates to the assets bucket. **Be sure to renew and replace certificates before the old ones expire!**

## TODO
- [x] Create `refresh-pki.sh` script
- Improve documentation
 - [ ] process
 - [ ] caveats
 - [ ] modules
 - [ ] ...
- etcd v3 migration path
 - [x] create
 - [ ] document
