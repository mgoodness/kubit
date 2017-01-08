data "aws_iam_policy_document" "controllers" {
  statement {
    actions = [
      "ec2:*",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "elasticloadbalancing:*",
      "sts:AssumeRole"
    ]
    resources = ["*"]
  }
  statement {
    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.assets_bucket_name}/*"]
  }
}

data "aws_iam_policy_document" "controllers_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_instance_profile" "controllers" {
  name = "${var.cluster_name}-controllers"
  roles = ["${aws_iam_role.controllers.name}"]
}

resource "aws_iam_role" "controllers" {
  assume_role_policy = "${data.aws_iam_policy_document.controllers_assume_role.json}"
  name = "${var.cluster_name}-controllers"
}

resource "aws_iam_role_policy" "controllers" {
  name = "${var.cluster_name}-controllers"
  policy = "${data.aws_iam_policy_document.controllers.json}"
  role = "${aws_iam_role.controllers.id}"
}
