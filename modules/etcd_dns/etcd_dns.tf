resource "aws_route53_record" "etcd_clients" {
  name = "_etcd-client-ssl._tcp.${var.internal_domain_name}"
  ttl = 30
  type = "SRV"
  records = ["${formatlist("0 0 2379 %s", var.etcd_node_fqdns)}"]
  zone_id = "${var.internal_domain_zone_id}"
}

resource "aws_route53_record" "etcd_servers" {
  name = "_etcd-server-ssl._tcp.${var.internal_domain_name}"
  ttl = 30
  type = "SRV"
  records = ["${formatlist("0 0 2380 %s", var.etcd_node_fqdns)}"]
  zone_id = "${var.internal_domain_zone_id}"
}
