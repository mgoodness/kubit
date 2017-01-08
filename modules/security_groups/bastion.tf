resource "aws_security_group" "bastion" {
  name = "${var.cluster_name}-bastion"
  vpc_id = "${var.vpc_id}"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = -1
    to_port = 0
  }
  /*SSH*/
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  tags { Name = "${var.cluster_name}-bastion" }
}
