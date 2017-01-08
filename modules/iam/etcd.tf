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
