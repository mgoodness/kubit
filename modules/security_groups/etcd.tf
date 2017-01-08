resource "aws_security_group" "etcd_protocol" {
  name = "${var.cluster_name}-etcd-protocol"
  vpc_id = "${var.vpc_id}"
  /*etcd*/
  egress {
    from_port = 2379
    protocol = "tcp"
    self = true
    to_port = 2380
  }
  /*etcd*/
  ingress {
    from_port = 2379
    protocol = "tcp"
    self = true
    to_port = 2380
  }
  tags {
    Name = "${var.cluster_name}-etcd-protocol"
  }
}

resource "aws_security_group" "etcd_cluster" {
  name = "${var.cluster_name}-etcd-cluster"
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
  tags {
    Name = "${var.cluster_name}-etcd-cluster"
  }
}
