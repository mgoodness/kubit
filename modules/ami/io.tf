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

variable "aws_region" { default = "us-east-1" }
variable "coreos_channel" { default = "stable" }
variable "coreos_version" { default = "*" }
variable "encrypted" { default = false }
variable "kms_key_id" { default = "" }
variable "owners" { default = [595879546273] }

output "ami_id" {
  value = "${var.encrypted ? join("", aws_ami_copy.coreos_encrypted.*.id) : data.aws_ami.coreos.id}"
}
