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

resource "aws_security_group" "nodes" {
  name = "${var.cluster_name}-k8s-nodes"
  vpc_id = "${var.vpc_id}"
  /*Flannel*/
  ingress {
    from_port = 8472
    protocol = "udp"
    self = true
    to_port = 8472
  }
  /*Kubelet secure*/
  ingress {
    from_port = 10250
    protocol = "tcp"
    self = true
    to_port = 10250
  }
  /*Kubelet read-only*/
  ingress {
    from_port = 10255
    protocol = "tcp"
    self = true
    to_port = 10255
  }
  tags {
    Name = "${var.cluster_name}-k8s-nodes"
  }
}
