variable "domain_names" { type = "map" }
variable "vpc_id" {}


output "domain_zone_ids" {
  value = {
    "external" = "${aws_route53_zone.external.id}"
    "internal" = "${aws_route53_zone.internal.id}"
  }
}
output "external_domain_servers" {
  value = "${aws_route53_zone.external.name_servers}"
}
