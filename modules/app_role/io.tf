variable "app_name" {}
variable "node_role_arns" { type = "list" }
variable "role_policy_document" {}


output "name" { value = "${aws_iam_role.role.name}" }
