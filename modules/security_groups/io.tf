/*
Copyright 2017 Michael Goodness

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

variable "access_cidr_blocks" { default = [], type = "list" }
variable "cluster_name" {}
variable "environment_name" {}
variable "vpc_cidr_block" {}
variable "vpc_id" {}


output "bastion" { value = "${aws_security_group.bastion.id}" }
output "controllers" { value = "${aws_security_group.controllers.id}" }
output "controllers_elb" { value = "${aws_security_group.controllers_elb.id}" }
output "etcd_cluster" { value = "${aws_security_group.etcd_cluster.id}" }
output "etcd_protocol" { value = "${aws_security_group.etcd_protocol.id}" }
output "nodes" { value = "${aws_security_group.nodes.id}" }
output "workers" {
  value = [
    "${aws_security_group.workers_dynamic.id}",
    "${aws_security_group.workers_static.id}"
  ]
}
