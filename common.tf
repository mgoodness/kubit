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

provider "aws" { region = "${var.aws_region}" }

module "bastion" {
  source = "./modules/bastion"
  cluster_name = "${var.cluster["name"]}"
  environment_name = "${var.environment_name}"
  public_subnet_id = "${element(module.vpc.public_subnet_ids, 0)}"
  security_groups = ["${module.security_groups.bastion}"]
  ssh_key_name = "${aws_key_pair.key_pair.key_name}"
}

module "common_dns" {
  source = "./modules/common_dns"
  domain_names = "${var.domain_names}"
  vpc_id = "${module.vpc.vpc_id}"
}

module "iam" {
  source = "./modules/iam"
  assets_bucket_name = "${var.assets_bucket_name}"
  cluster_name = "${var.cluster["name"]}"
  environment_name = "${var.environment_name}"
}

module "security_groups" {
  source = "./modules/security_groups"
  cluster_name = "${var.cluster["name"]}"
  environment_name = "${var.environment_name}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
  vpc_id = "${module.vpc.vpc_id}"
}

module "vpc" {
  source = "./modules/vpc"
  cidr_block = "${var.vpc_cidr_block}"
  environment_name = "${var.environment_name}"
  region = "${var.aws_region}"
  subnets = ["${var.subnets}"]
}

resource "aws_key_pair" "key_pair" {
  key_name = "${var.cluster["name"]}"
  public_key = "${file(format("keys/%s.pub", var.cluster["name"]))}"
}
