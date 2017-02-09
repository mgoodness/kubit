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

data "template_file" "private_az" {
  count = "${length(var.subnets["availability_zones"])}"
  template = "${format("%s%s", var.region, element(var.subnets["availability_zones"], count.index))}"
}

resource "aws_route_table" "private" {
  count = "${length(var.subnets["availability_zones"])}"
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(var.nat_gateway_ids, count.index)}"
  }
  tags {
    Name = "${format("%s-private-%s", var.name, element(var.subnets["availability_zones"], count.index))}"
  }
}

resource "aws_route_table_association" "private" {
  count = "${length(var.subnets["private_cidr_blocks"])}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
}

resource "aws_subnet" "private" {
  count = "${length(var.subnets["private_cidr_blocks"])}"
  availability_zone = "${element(data.template_file.private_az.*.rendered, count.index)}"
  cidr_block = "${element(var.subnets["private_cidr_blocks"], count.index)}"
  map_public_ip_on_launch = false
  vpc_id = "${var.vpc_id}"
  tags {
    "kubernetes.io/role/internal-elb" = "true"
    KubernetesCluster = "${var.name}"
    Name = "${format("%s-private-%s", var.name, element(var.subnets["availability_zones"], count.index))}"
  }
}
