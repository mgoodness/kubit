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
