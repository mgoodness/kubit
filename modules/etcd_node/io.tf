variable "assets_bucket_name" {}
variable "availability_zone" {}
variable "cluster_name" {}
variable "coreos_channel" { default = "stable" }
variable "instance_profile" {}
variable "instance_type" { default = "m4.large" }
variable "internal_domain_name" {}
variable "internal_domain_zone_id" {}
variable "private_subnet_id" {}
variable "region" {}
variable "security_groups" { type = "list" }
variable "ssh_key_name" {}
variable "unique_id" {}
variable "version" { default = 2 }


output "fqdn" { value = "${aws_route53_record.etcd.fqdn}" }
