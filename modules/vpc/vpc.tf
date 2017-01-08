resource "aws_vpc" "main" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = true
  tags {
    KubernetesCluster = "${var.cluster_name}"
    Name = "${var.cluster_name}"
  }
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name = "${var.region == "us-east-1" ? "ec2.internal" : format("%s.compute.internal", var.region)}"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags { Name = "${var.cluster_name}" }
}

resource "aws_vpc_dhcp_options_association" "main" {
  dhcp_options_id = "${aws_vpc_dhcp_options.main.id}"
  vpc_id = "${aws_vpc.main.id}"
}
