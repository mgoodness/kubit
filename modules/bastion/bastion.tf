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
  owners = [595879546273]
  filter {
    name = "name"
    values = ["CoreOS-${var.coreos_channel}-*-hvm"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.coreos.id}"
  associate_public_ip_address = true
  instance_type = "${var.instance_type}"
  key_name = "${var.ssh_key_name}"
  source_dest_check = false
  subnet_id = "${var.public_subnet_id}"
  vpc_security_group_ids = ["${var.security_groups}"]
  tags { Name = "${var.environment_name}-${var.cluster_name}-bastion" }
}
