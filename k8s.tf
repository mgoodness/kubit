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

module "controllers" {
  source = "./modules/controllers"
  assets_bucket_name = "${var.assets_bucket_name}"
  cluster = "${var.cluster}"
  domain_names = "${var.domain_names}"
  domain_zone_ids = "${module.common_dns.domain_zone_ids}"
  elb_idle_timeout = 300
  elb_security_groups = ["${module.security_groups.controllers_elb}"]
  environment_name = "${var.environment_name}"
  hyperkube = "${var.hyperkube}"
  instance_profile = "${module.iam.controllers_instance_profile}"
  instance_security_groups = [
    "${module.security_groups.controllers}",
    "${module.security_groups.etcd_protocol}",
    "${module.security_groups.nodes}"
  ]
  private_subnet_ids = ["${module.subnet_private.subnet_ids}"]
  public_subnet_ids = ["${module.subnet_public.subnet_ids}"]
  ssh_key_name = "${aws_key_pair.key_pair.key_name}"
}

module "workers_t2_large_0" {
  source = "./modules/worker_pool"
  assets_bucket_name = "${var.assets_bucket_name}"
  availability_zone = "${element(var.subnets["availability_zones"], 0)}"
  cluster = "${var.cluster}"
  controller_endpoint = "${module.controllers.internal_endpoint}"
  environment_name = "${var.environment_name}"
  hyperkube = "${var.hyperkube}"
  instance_profile = "${module.iam.workers_instance_profile}"
  instance_type = "t2.large"
  internal_domain_name = "${var.domain_names["internal"]}"
  security_groups = [
    "${module.security_groups.etcd_protocol}",
    "${module.security_groups.nodes}",
    "${module.security_groups.workers}"
  ]
  ssh_key_name = "${aws_key_pair.key_pair.key_name}"
  subnet_id = "${element(module.subnet_private.subnet_ids, 0)}"
  tls_token = "${module.controllers.tls_token}"
}

module "workers_t2_large_1" {
  source = "./modules/worker_pool"
  assets_bucket_name = "${var.assets_bucket_name}"
  availability_zone = "${element(var.subnets["availability_zones"], 1)}"
  cluster = "${var.cluster}"
  controller_endpoint = "${module.controllers.internal_endpoint}"
  environment_name = "${var.environment_name}"
  hyperkube = "${var.hyperkube}"
  instance_profile = "${module.iam.workers_instance_profile}"
  instance_type = "t2.large"
  internal_domain_name = "${var.domain_names["internal"]}"
  security_groups = [
    "${module.security_groups.etcd_protocol}",
    "${module.security_groups.nodes}",
    "${module.security_groups.workers}"
  ]
  ssh_key_name = "${aws_key_pair.key_pair.key_name}"
  subnet_id = "${element(module.subnet_private.subnet_ids, 1)}"
  tls_token = "${module.controllers.tls_token}"
}

module "workers_t2_large_2" {
  source = "./modules/worker_pool"
  assets_bucket_name = "${var.assets_bucket_name}"
  availability_zone = "${element(var.subnets["availability_zones"], 2)}"
  cluster = "${var.cluster}"
  controller_endpoint = "${module.controllers.internal_endpoint}"
  environment_name = "${var.environment_name}"
  hyperkube = "${var.hyperkube}"
  instance_profile = "${module.iam.workers_instance_profile}"
  instance_type = "t2.large"
  internal_domain_name = "${var.domain_names["internal"]}"
  security_groups = [
    "${module.security_groups.etcd_protocol}",
    "${module.security_groups.nodes}",
    "${module.security_groups.workers}"
  ]
  ssh_key_name = "${aws_key_pair.key_pair.key_name}"
  subnet_id = "${element(module.subnet_private.subnet_ids, 0)}"
  tls_token = "${module.controllers.tls_token}"
}
