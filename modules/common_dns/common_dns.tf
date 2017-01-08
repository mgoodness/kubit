resource "aws_route53_zone" "external" { name = "${var.domain_names["external"]}" }

resource "aws_route53_zone" "internal" {
  name = "${var.domain_names["internal"]}"
  vpc_id = "${var.vpc_id}"
}
