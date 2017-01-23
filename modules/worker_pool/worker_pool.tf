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

data "template_file" "pool_name" {
  template = "${var.cluster["name"]}-workers-${replace(var.instance_type, ".", "-")}-${var.availability_zone}"
}

data "template_file" "pool_config" {
  template = "${file("${path.module}/worker_pool.yaml")}"
  vars {
    ASSETS_BUCKET_NAME = "${var.assets_bucket_name}"
    CONTROLLER_ENDPOINT = "${var.controller_endpoint}"
    DNS_SERVICE_IP = "${cidrhost(var.cluster["services_cidr_block"], 10)}"
    HYPERKUBE_REPO = "${var.hyperkube["repository"]}"
    HYPERKUBE_VERSION = "${var.hyperkube["version"]}"
    INTERNAL_DOMAIN = "${var.internal_domain_name}"
    LOCKSMITH_GROUP= "${data.template_file.pool_name.rendered}"
    TLS_TOKEN = "${var.tls_token}"
    UPDATE_GROUP = "${var.coreos_channel}"
  }
}

resource "aws_autoscaling_group" "pool" {
  launch_configuration = "${aws_launch_configuration.pool.name}"
  max_size = "${var.max_pool_size}"
  min_size = "${var.min_pool_size}"
  name = "${data.template_file.pool_name.rendered}"
  vpc_zone_identifier = ["${var.subnet_id}"]
  tag {
    key = "KubernetesCluster"
    propagate_at_launch = true
    value = "${var.cluster["name"]}"
  }
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "${data.template_file.pool_name.rendered}"
  }
}

resource "aws_launch_configuration" "pool" {
  iam_instance_profile = "${var.instance_profile}"
  image_id = "${data.aws_ami.coreos.id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.ssh_key_name}"
  name_prefix = "${data.template_file.pool_name.rendered}-"
  security_groups = ["${var.security_groups}"]
  spot_price = "${var.spot_price}"
  user_data = "${data.template_file.pool_config.rendered}"
  lifecycle { create_before_destroy = true }
  root_block_device {
    volume_size = "${var.volume_size}"
    volume_type = "${var.volume_type}"
  }
}
