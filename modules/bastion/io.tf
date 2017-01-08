variable "cluster_name" {}
variable "coreos_channel" { default = "stable" }
variable "instance_type" { default = "t2.nano" }
variable "public_subnet_id" {}
variable "security_groups" { type = "list" }
variable "ssh_key_name" {}


output "fqdn" { value = "${aws_instance.bastion.public_dns}" }
