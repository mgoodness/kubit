/*
Copyright 2017 Michael Goodness

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

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
