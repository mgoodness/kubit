variable "assets_bucket_name" {}
variable "aws_region" { default = "us-east-1" }
variable "cluster" {
  default = {
    name = "kubit"
    pods_cidr_block = "10.251.0.0/16"
    services_cidr_block = "10.252.0.0/16"
  }
}
variable "domain_names" { default = { internal = "kubit.local" } }
variable "hyperkube" {
  default = {
    repository = "quay.io/coreos/hyperkube"
    version = "v1.5.1_coreos.0"
  }
}
variable "subnets" {
  default = {
    availability_zones = ["a","b","c"]
    private_cidr_blocks = ["10.150.10.0/24","10.150.20.0/24","10.150.30.0/24"]
    public_cidr_blocks = ["10.150.1.0/24","10.150.2.0/24","10.150.3.0/24"]
  }
}
variable "vpc_cidr_block" { default = "10.150.0.0/16" }


output "bastion_connection" {
  value = "ssh -i ~/.ssh/${var.cluster["name"]} -A core@${module.bastion.fqdn}"
}
output "etcd_nodes" {
  value = "${formatlist("%s", list(module.etcd_node_01.fqdn, module.etcd_node_02.fqdn, module.etcd_node_03.fqdn))}"
}
output "external_controller_endpoint" {
  value = "${module.controllers.external_endpoint}"
}
output "external_domain_servers" {
  value = "${module.common_dns.external_domain_servers}"
}
