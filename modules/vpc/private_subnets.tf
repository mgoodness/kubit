data "template_file" "private_az" {
  count = "${length(var.subnets["availability_zones"])}"
  template = "${format("%s%s", var.region, element(var.subnets["availability_zones"], count.index))}"
}

resource "aws_eip" "nat" { vpc = true }

resource "aws_nat_gateway" "nat" {
  depends_on = [
    "aws_eip.nat",
    "aws_internet_gateway.gateway"
  ]
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.public.0.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }
  tags {
    KubernetesCluster = "${var.cluster_name}"
    Name = "${var.cluster_name}-private"
  }
}

resource "aws_route_table_association" "private" {
  count = "${length(var.subnets["private_cidr_blocks"])}"
  route_table_id = "${aws_route_table.private.id}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
}

resource "aws_subnet" "private" {
  count = "${length(var.subnets["private_cidr_blocks"])}"
  availability_zone = "${element(data.template_file.private_az.*.rendered, count.index)}"
  cidr_block = "${element(var.subnets["private_cidr_blocks"], count.index)}"
  map_public_ip_on_launch = false
  vpc_id = "${aws_vpc.main.id}"
  tags {
    "kubernetes.io/role/internal-elb" = "true"
    KubernetesCluster = "${var.cluster_name}"
    Name = "${format("%s-public-%s", var.cluster_name, element(var.subnets["availability_zones"], count.index))}"
  }
}
