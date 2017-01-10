variable "etcd_node_fqdns" { type = "list" }
variable "internal_domain_name" {}
variable "internal_domain_zone_id" {}


output "depends_id" { value = "${null_resource.etcd_dns.id}" }
