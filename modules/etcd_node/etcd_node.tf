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

data "template_file" "etcd" {
  template = "${file("${path.module}/etcd_v${var.version}.yaml")}"
  vars {
    ASSETS_BUCKET_NAME = "${var.assets_bucket_name}"
    CLUSTER_NAME = "${var.cluster_name}"
    DOMAIN = "${var.internal_domain_name}"
    FQDN = "${var.cluster_name}-etcd-${var.unique_id}.${var.internal_domain_name}"
    NODE_NAME = "${var.cluster_name}-etcd-${var.unique_id}"
    UPDATE_GROUP = "${var.coreos_channel}"
  }
}

resource "aws_cloudwatch_metric_alarm" "etcd_recover" {
  alarm_actions = ["arn:aws:automate:${var.region}:ec2:recover"]
  alarm_description = "Recover ${var.cluster_name}-etcd-${var.unique_id}"
  alarm_name = "${var.cluster_name}-etcd-${var.unique_id}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  metric_name = "StatusCheckFailed_System"
  namespace = "AWS/EC2"
  period = 60
  statistic = "Minimum"
  threshold = 0
  dimensions { InstanceId = "${aws_instance.etcd.id}" }
}

resource "aws_ebs_volume" "etcd" {
  availability_zone = "${format("%s%s", var.region, var.availability_zone)}"
  size = 4
  type = "gp2"
  tags { Name = "${var.cluster_name}-etcd-${var.unique_id}" }
}

resource "aws_instance" "etcd" {
  ami = "${var.ami_id}"
  iam_instance_profile = "${var.instance_profile}"
  instance_type = "${var.instance_type}"
  key_name = "${var.ssh_key_name}"
  monitoring = true
  subnet_id = "${var.private_subnet_id}"
  user_data = "${data.template_file.etcd.rendered}"
  vpc_security_group_ids = ["${var.security_groups}"]
  lifecycle { ignore_changes = ["ami"] }
  tags { Name = "${var.cluster_name}-etcd-${var.unique_id}" }
}

resource "aws_route53_record" "etcd" {
  name = "${var.cluster_name}-etcd-${var.unique_id}.${var.internal_domain_name}"
  ttl = 30
  type = "A"
  records = ["${aws_instance.etcd.private_ip}"]
  zone_id = "${var.internal_domain_zone_id}"
}

resource "aws_volume_attachment" "etcd" {
  device_name = "/dev/xvdf"
  instance_id = "${aws_instance.etcd.id}"
  skip_destroy = true
  volume_id = "${aws_ebs_volume.etcd.id}"
}
