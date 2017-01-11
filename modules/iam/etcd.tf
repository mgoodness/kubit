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

data "aws_iam_policy_document" "etcd" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.assets_bucket_name}/*"]
  }
}

data "aws_iam_policy_document" "etcd_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_instance_profile" "etcd" {
  name = "${var.cluster_name}-etcd"
  roles = ["${aws_iam_role.etcd.name}"]
}

resource "aws_iam_role" "etcd" {
  assume_role_policy = "${data.aws_iam_policy_document.etcd_assume_role.json}"
  name = "${var.cluster_name}-etcd"
}

resource "aws_iam_role_policy" "etcd" {
  name = "${var.cluster_name}-etcd"
  policy = "${data.aws_iam_policy_document.etcd.json}"
  role = "${aws_iam_role.etcd.id}"
}
