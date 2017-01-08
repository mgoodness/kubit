resource "aws_security_group" "workers" {
  name = "${var.cluster_name}-k8s-workers"
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
  /*NFS*/
  ingress {
    from_port = 2049
    protocol = "tcp"
    self = true
    to_port = 2049
  }
  lifecycle { ignore_changes = ["ingress"] }
  tags {
    KubernetesCluster = "${var.cluster_name}"
    Name = "${var.cluster_name}-k8s-workers"
  }
}
