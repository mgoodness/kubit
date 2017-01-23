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
variable "cluster" { type = "map" }
variable "controller_endpoint" {}
variable "coreos_channel" { default = "stable" }
variable "hyperkube" { type = "map" }
variable "instance_profile" {}
variable "instance_type" {}
variable "internal_domain_name" {}
variable "max_pool_size" { default = 64 }
variable "min_pool_size" { default = 1 }
variable "security_groups" { type = "list" }
variable "spot_price" { default = "" }
variable "ssh_key_name" {}
variable "subnet_id" {}
variable "tls_token" {}
variable "volume_size" { default = 32 }
variable "volume_type" { default = "gp2" }
