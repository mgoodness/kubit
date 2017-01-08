resource "aws_route53_record" "external" {
  name = "kubernetes.${var.domain_names["external"]}"
  type = "A"
  zone_id = "${var.domain_zone_ids["external"]}"
  alias {
    evaluate_target_health = true
    name = "${aws_elb.controllers.dns_name}"
    zone_id = "${aws_elb.controllers.zone_id}"
  }
}

resource "aws_route53_record" "internal" {
  name = "kubernetes.${var.domain_names["internal"]}"
  type = "A"
  zone_id = "${var.domain_zone_ids["internal"]}"
  alias {
    evaluate_target_health = true
    name = "${aws_elb.controllers.dns_name}"
    zone_id = "${aws_elb.controllers.zone_id}"
  }
}
