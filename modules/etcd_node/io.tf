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

variable "assets_bucket_name" {}
variable "availability_zone" {}
variable "cluster_name" {}
variable "coreos_channel" { default = "stable" }
variable "ebs_encrypted" {}
variable "instance_profile" {}
variable "instance_type" { default = "m4.large" }
variable "internal_domain_name" {}
variable "internal_domain_zone_id" {}
variable "kms_key_id" {}
variable "private_subnet_id" {}
variable "region" {}
variable "security_groups" { type = "list" }
variable "ssh_key_name" {}
variable "unique_id" {}
variable "version" { default = 3 }


output "fqdn" { value = "${aws_route53_record.etcd.fqdn}" }
