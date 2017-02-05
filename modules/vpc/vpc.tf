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

resource "aws_vpc" "main" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = true
  tags { Name = "${var.environment_name}" }
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name = "${var.region == "us-east-1" ? "ec2.internal" : format("%s.compute.internal", var.region)}"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags { Name = "${var.environment_name}" }
}

resource "aws_vpc_dhcp_options_association" "main" {
  dhcp_options_id = "${aws_vpc_dhcp_options.main.id}"
  vpc_id = "${aws_vpc.main.id}"
}
