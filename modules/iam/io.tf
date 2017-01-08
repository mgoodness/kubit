variable "assets_bucket_name" {}
variable "cluster_name" {}


output "controllers_instance_profile" { value = "${aws_iam_instance_profile.controllers.id}" }
output "etcd_instance_profile" { value = "${aws_iam_instance_profile.etcd.id}" }
output "workers_instance_profile" { value = "${aws_iam_instance_profile.workers.id}" }
