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

data "template_file" "controllers_config" {
  template = "${file("${path.module}/controllers.yaml")}"
  vars {
    APISERVER_COUNT = "${var.controller_count}"
    ASSETS_BUCKET_NAME = "${var.assets_bucket_name}"
    DNS_SERVICE_IP = "${cidrhost(var.cluster["services_cidr_block"], 10)}"
    HYPERKUBE_REPO = "${var.hyperkube["repository"]}"
    HYPERKUBE_VERSION = "${var.hyperkube["version"]}"
    INTERNAL_DOMAIN = "${var.domain_names["internal"]}"
    PODS_CIDR_BLOCK = "${var.cluster["pods_cidr_block"]}"
    SERVICES_CIDR_BLOCK = "${var.cluster["services_cidr_block"]}"
    TLS_TOKEN = "${random_id.tls_token.hex}"
    UPDATE_GROUP = "${var.coreos_channel}"
  }
}

resource "aws_autoscaling_group" "controllers" {
  desired_capacity = "${var.controller_count}"
  health_check_type = "ELB"
  launch_configuration = "${aws_launch_configuration.controllers.name}"
  load_balancers = ["${aws_elb.controllers.name}"]
  max_size = "${var.max_nodes}"
  min_size = "${var.min_nodes}"
  name = "${var.cluster["name"]}-controllers"
  vpc_zone_identifier = ["${var.private_subnet_ids}"]
  wait_for_elb_capacity = 1
  tag {
    key = "KubernetesCluster"
    propagate_at_launch = true
    value = "${var.cluster["name"]}"
  }
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "${var.cluster["name"]}-controller"
  }
}

resource "aws_elb" "controllers" {
  connection_draining = true
  idle_timeout = "${var.elb_idle_timeout}"
  name = "${var.cluster["name"]}-controllers"
  security_groups = ["${var.elb_security_groups}"]
  subnets = ["${var.public_subnet_ids}"]
  health_check {
    healthy_threshold = 3
    interval = 20
    target = "TCP:443"
    timeout = 5
    unhealthy_threshold = 6
  }
  listener {
    instance_port = 443
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }
  tags { Name = "${var.cluster["name"]}-controllers" }
}

resource "aws_launch_configuration" "controllers" {
  iam_instance_profile = "${var.instance_profile}"
  image_id = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.ssh_key_name}"
  name_prefix = "${var.cluster["name"]}-controllers-"
  security_groups = ["${var.instance_security_groups}"]
  user_data = "${data.template_file.controllers_config.rendered}"
  lifecycle { create_before_destroy = true }
  root_block_device {
    volume_size = 32
    volume_type = "gp2"
  }
}

resource "random_id" "tls_token" { byte_length = 16 }
