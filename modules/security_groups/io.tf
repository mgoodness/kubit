variable "access_cidr_blocks" { default = [], type = "list" }
variable "cluster_name" {}
variable "vpc_cidr_block" {}
variable "vpc_id" {}


output "bastion" { value = "${aws_security_group.bastion.id}" }
output "controllers" { value = "${aws_security_group.controllers.id}" }
output "controllers_elb" { value = "${aws_security_group.controllers_elb.id}" }
output "etcd_cluster" { value = "${aws_security_group.etcd_cluster.id}" }
output "etcd_protocol" { value = "${aws_security_group.etcd_protocol.id}" }
output "nodes" { value = "${aws_security_group.nodes.id}" }
output "workers" { value = "${aws_security_group.workers.id}" }
