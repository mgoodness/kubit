module "etcd_node_01" {
  source = "./modules/etcd_node"
  assets_bucket_name = "${var.assets_bucket_name}"
  availability_zone = "${element(var.subnets["availability_zones"], 0)}"
  cluster_name = "${var.cluster["name"]}"
  instance_profile = "${module.iam.etcd_instance_profile}"
  internal_domain_name = "${var.domain_names["internal"]}"
  internal_domain_zone_id = "${module.common_dns.domain_zone_ids["internal"]}"
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
  instance_profile = "${module.iam.etcd_instance_profile}"
  internal_domain_name = "${var.domain_names["internal"]}"
  internal_domain_zone_id = "${module.common_dns.domain_zone_ids["internal"]}"
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
  instance_profile = "${module.iam.etcd_instance_profile}"
  internal_domain_name = "${var.domain_names["internal"]}"
  internal_domain_zone_id = "${module.common_dns.domain_zone_ids["internal"]}"
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
