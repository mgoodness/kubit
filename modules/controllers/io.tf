variable "assets_bucket_name" {}
variable "cluster" { type = "map" }
variable "controller_count" { default = 2 }
variable "coreos_channel" { default = "stable" }
variable "depends_id" {}
variable "domain_names" { type = "map" }
variable "domain_zone_ids" { type = "map" }
variable "elb_security_groups" { type = "list" }
variable "hyperkube" { type = "map" }
variable "instance_profile" {}
variable "instance_security_groups" { type = "list" }
variable "instance_type" { default = "m4.large" }
variable "max_nodes" { default = 3 }
variable "min_nodes" { default = 1 }
variable "private_subnet_ids" { type = "list" }
variable "public_subnet_ids" { type = "list" }
variable "ssh_key_name" {}


output "external_endpoint" { value = "https://${aws_route53_record.external.fqdn}" }
output "internal_endpoint" { value = "https://${aws_route53_record.internal.fqdn}" }
