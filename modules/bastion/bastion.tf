data "aws_ami" "coreos" {
  most_recent = true
  owners = [595879546273]
  filter {
    name = "name"
    values = ["CoreOS-${var.coreos_channel}-*-hvm"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.coreos.id}"
  associate_public_ip_address = true
  instance_type = "${var.instance_type}"
  key_name = "${var.ssh_key_name}"
  source_dest_check = false
  subnet_id = "${var.public_subnet_id}"
  vpc_security_group_ids = ["${var.security_groups}"]
  tags { Name = "${var.cluster_name}-bastion" }
}
