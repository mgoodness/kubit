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

resource "aws_route53_record" "external" {
  name = "kubernetes.${var.environment_name}-${var.cluster["name"]}.${var.domain_names["external"]}"
  type = "A"
  zone_id = "${var.domain_zone_ids["external"]}"
  alias {
    evaluate_target_health = true
    name = "${aws_elb.controllers.dns_name}"
    zone_id = "${aws_elb.controllers.zone_id}"
  }
}

resource "aws_route53_record" "internal" {
  name = "kubernetes.${var.environment_name}-${var.cluster["name"]}.${var.domain_names["internal"]}"
  type = "A"
  zone_id = "${var.domain_zone_ids["internal"]}"
  alias {
    evaluate_target_health = true
    name = "${aws_elb.controllers.dns_name}"
    zone_id = "${aws_elb.controllers.zone_id}"
  }
}
