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
