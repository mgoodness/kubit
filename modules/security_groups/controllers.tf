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

resource "aws_security_group" "controllers" {
  name = "${var.cluster_name}-k8s-controllers"
  vpc_id = "${var.vpc_id}"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = -1
    to_port = 0
  }
  /*ICMP*/
  ingress {
    cidr_blocks = [
      "${var.access_cidr_blocks}",
      "${var.vpc_cidr_block}"
    ]
    from_port = -1
    protocol = "icmp"
    to_port = -1
  }
  /*SSH*/
  ingress {
    cidr_blocks = [
      "${var.access_cidr_blocks}",
      "${var.vpc_cidr_block}"
    ]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  /*HTTPS*/
  ingress {
    cidr_blocks = ["${var.vpc_cidr_block}"]
    from_port = 443
    protocol = "tcp"
    to_port = 443
  }
  /*HTTP*/
  ingress {
    cidr_blocks = ["${var.vpc_cidr_block}"]
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
  }
  /*Controller-manager*/
  ingress {
    from_port = 10252
    protocol = "tcp"
    security_groups = ["${aws_security_group.workers.id}"]
    to_port = 10252
  }
  /*Scheduler*/
  ingress {
    from_port = 10251
    protocol = "tcp"
    security_groups = ["${aws_security_group.workers.id}"]
    to_port = 10251
  }
  tags {
    KubernetesCluster = "${var.cluster_name}"
    Name = "${var.cluster_name}-k8s-controllers"
  }
}

resource "aws_security_group" "controllers_elb" {
  name = "${var.cluster_name}-k8s-controllers-elb"
  vpc_id = "${var.vpc_id}"
  /*HTTPS*/
  egress {
    from_port = 443
    protocol = "tcp"
    security_groups = ["${aws_security_group.controllers.id}"]
    to_port = 443
  }
  /*HTTPS*/
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 443
    protocol = "tcp"
    to_port = 443
  }
  tags {
    Name = "${var.cluster_name}-k8s-controllers-elb"
  }
}
