data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["${var.node_role_arns}"]
      type = "AWS"
    }
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "role" {
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
  name = "${var.app_name}"
}

resource "aws_iam_role_policy" "policy" {
  name = "${var.app_name}"
  policy = "${var.role_policy_document}"
  role = "${aws_iam_role.role.id}"
}
