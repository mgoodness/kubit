data "template_file" "public_az" {
  count = "${length(var.subnets["availability_zones"])}"
  template = "${format("%s%s", var.region, element(var.subnets["availability_zones"], count.index))}"
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
    KubernetesCluster = "${var.cluster_name}"
    Name = "${var.cluster_name}"
  }
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gateway.id}"
  route_table_id = "${aws_vpc.main.main_route_table_id}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.subnets["public_cidr_blocks"])}"
  route_table_id = "${aws_vpc.main.main_route_table_id}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
}

resource "aws_subnet" "public" {
  count = "${length(var.subnets["public_cidr_blocks"])}"
  availability_zone = "${element(data.template_file.public_az.*.rendered, count.index)}"
  cidr_block = "${element(var.subnets["public_cidr_blocks"], count.index)}"
  map_public_ip_on_launch = true
  vpc_id = "${aws_vpc.main.id}"
  tags {
    "kubernetes.io/role/elb" = "true"
    KubernetesCluster = "${var.cluster_name}"
    Name = "${format("%s-public-%s", var.cluster_name, element(var.subnets["availability_zones"], count.index))}"
  }
}
