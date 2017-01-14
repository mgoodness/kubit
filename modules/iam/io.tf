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

variable "assets_bucket_name" {}
variable "cluster_name" {}


output "controllers_instance_profile" { value = "${aws_iam_instance_profile.controllers.id}" }
output "controllers_role_arn" { value = "${aws_iam_role.controllers.arn}" }
output "etcd_instance_profile" { value = "${aws_iam_instance_profile.etcd.id}" }
output "workers_instance_profile" { value = "${aws_iam_instance_profile.workers.id}" }
output "workers_role_arn" { value = "${aws_iam_role.workers.arn}" }
