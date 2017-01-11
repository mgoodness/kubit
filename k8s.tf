module "controllers" {
  source = "./modules/controllers"
  assets_bucket_name = "${var.assets_bucket_name}"
  cluster = "${var.cluster}"
  depends_id = "${module.etcd_dns.depends_id}"
  domain_names = "${var.domain_names}"
  domain_zone_ids = "${module.common_dns.domain_zone_ids}"
  elb_security_groups = ["${module.security_groups.controllers_elb}"]
  hyperkube = "${var.hyperkube}"
  instance_profile = "${module.iam.controllers_instance_profile}"
  instance_security_groups = [
    "${module.security_groups.controllers}",
    "${module.security_groups.etcd_protocol}",
    "${module.security_groups.nodes}"
  ]
  private_subnet_ids = ["${module.vpc.private_subnet_ids}"]
  public_subnet_ids = ["${module.vpc.public_subnet_ids}"]
  ssh_key_name = "${aws_key_pair.key_pair.key_name}"
}

module "workers_t2_large_a" {
  source = "./modules/worker_pool"
  assets_bucket_name = "${var.assets_bucket_name}"
  availability_zone = "${element(var.subnets["availability_zones"], 0)}"
  cluster = "${var.cluster}"
  controller_endpoint = "${module.controllers.internal_endpoint}"
  depends_id = "${module.etcd_dns.depends_id}"
  hyperkube = "${var.hyperkube}"
  instance_profile = "${module.iam.workers_instance_profile}"
  instance_type = "t2.large"
  internal_domain_name = "${var.domain_names["internal"]}"
  security_groups = [
    "${module.security_groups.etcd_protocol}",
    "${module.security_groups.workers}"
  ]
  ssh_key_name = "${aws_key_pair.key_pair.key_name}"
  subnet_id = "${element(module.vpc.private_subnet_ids, 0)}"
}
