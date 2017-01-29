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

module "etcd_node_01" {
  source = "./modules/etcd_node"
  assets_bucket_name = "${var.assets_bucket_name}"
  availability_zone = "${element(var.subnets["availability_zones"], 0)}"
  cluster_name = "${var.cluster["name"]}"
  ebs_encrypted = "${var.ebs_encrypted}"
  instance_profile = "${module.iam.etcd_instance_profile}"
  internal_domain_name = "${var.domain_names["internal"]}"
  internal_domain_zone_id = "${module.common_dns.domain_zone_ids["internal"]}"
  kms_key_id = "${var.kms_key_id}"
  private_subnet_id = "${element(module.vpc.private_subnet_ids, 0)}"
  region = "${var.aws_region}"
  security_groups = [
    "${module.security_groups.etcd_cluster}",
    "${module.security_groups.etcd_protocol}"
  ]
  ssh_key_name = "${aws_key_pair.key_pair.key_name}"
  unique_id = "01"
}

module "etcd_node_02" {
  source = "./modules/etcd_node"
  assets_bucket_name = "${var.assets_bucket_name}"
  availability_zone = "${element(var.subnets["availability_zones"], 0)}"
  cluster_name = "${var.cluster["name"]}"
  ebs_encrypted = "${var.ebs_encrypted}"
  instance_profile = "${module.iam.etcd_instance_profile}"
  internal_domain_name = "${var.domain_names["internal"]}"
  internal_domain_zone_id = "${module.common_dns.domain_zone_ids["internal"]}"
  kms_key_id = "${var.kms_key_id}"
  private_subnet_id = "${element(module.vpc.private_subnet_ids, 0)}"
  region = "${var.aws_region}"
  security_groups = [
    "${module.security_groups.etcd_cluster}",
    "${module.security_groups.etcd_protocol}"
  ]
  ssh_key_name = "${aws_key_pair.key_pair.key_name}"
  unique_id = "02"
}

module "etcd_node_03" {
  source = "./modules/etcd_node"
  assets_bucket_name = "${var.assets_bucket_name}"
  availability_zone = "${element(var.subnets["availability_zones"], 0)}"
  cluster_name = "${var.cluster["name"]}"
  ebs_encrypted = "${var.ebs_encrypted}"
  instance_profile = "${module.iam.etcd_instance_profile}"
  internal_domain_name = "${var.domain_names["internal"]}"
  internal_domain_zone_id = "${module.common_dns.domain_zone_ids["internal"]}"
  kms_key_id = "${var.kms_key_id}"
  private_subnet_id = "${element(module.vpc.private_subnet_ids, 0)}"
  region = "${var.aws_region}"
  security_groups = [
    "${module.security_groups.etcd_cluster}",
    "${module.security_groups.etcd_protocol}"
  ]
  ssh_key_name = "${aws_key_pair.key_pair.key_name}"
  unique_id = "03"
}

module "etcd_dns" {
  source = "./modules/etcd_dns"
  etcd_node_fqdns = [
    "${module.etcd_node_01.fqdn}",
    "${module.etcd_node_02.fqdn}",
    "${module.etcd_node_03.fqdn}"
  ]
  internal_domain_name = "${var.domain_names["internal"]}"
  internal_domain_zone_id = "${module.common_dns.domain_zone_ids["internal"]}"
}
