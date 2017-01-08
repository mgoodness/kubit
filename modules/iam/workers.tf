data "aws_iam_policy_document" "workers" {
  statement {
    actions = [
      "ec2:AttachVolume",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:Describe*",
      "ec2:DetachVolume",
      "ec2:ReplaceRoute",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "sts:AssumeRole"
    ]
    resources = ["*"]
  }
  statement {
    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.assets_bucket_name}/*"]
  }
}

data "aws_iam_policy_document" "workers_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_instance_profile" "workers" {
  name = "${var.cluster_name}-workers"
  roles = ["${aws_iam_role.workers.name}"]
}

resource "aws_iam_role" "workers" {
  assume_role_policy = "${data.aws_iam_policy_document.workers_assume_role.json}"
  name = "${var.cluster_name}-workers"
}

resource "aws_iam_role_policy" "workers" {
  name = "${var.cluster_name}-workers"
  policy = "${data.aws_iam_policy_document.workers.json}"
  role = "${aws_iam_role.workers.id}"
}
