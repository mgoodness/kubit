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
variable "cluster" { type = "map" }
variable "controller_count" { default = 2 }
variable "coreos_channel" { default = "stable" }
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
output "tls_token" { value = "${random_id.tls_token.hex}" }
