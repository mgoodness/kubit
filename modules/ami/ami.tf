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

data "aws_ami" "coreos" {
  most_recent = true
  owners = "${var.owners}"
  filter {
    name = "name"
    values = ["CoreOS-${var.coreos_channel}-${var.coreos_version}-hvm"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_ami_copy" "coreos_encrypted" {
  count = "${var.encrypted ? 1 : 0}"
  name = "${data.aws_ami.coreos.name}-encrypted"
  description = "${data.aws_ami.coreos.description} Encrypted"
  source_ami_id = "${data.aws_ami.coreos.id}"
  source_ami_region = "${var.aws_region}"
  encrypted = true
  kms_key_id = "${var.kms_key_id}"
}
