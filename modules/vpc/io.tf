variable "cidr_block" {}
variable "cluster_name" {}
variable "subnets" { type = "map" }
variable "region" {}


output "main_route_table_id" { value = "${aws_vpc.main.main_route_table_id}" }
output "private_route_table_id" { value = "${aws_route_table.private.id}" }
output "private_subnet_ids" { value = ["${aws_subnet.private.*.id}"] }
output "public_subnet_ids" { value = ["${aws_subnet.public.*.id}"] }
output "vpc_id" { value = "${aws_vpc.main.id}" }
