provider "aws" { region = "${var.aws_region}" }

module "bastion" {
  source = "./modules/bastion"
  cluster_name = "${var.cluster["name"]}"
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
}

module "security_groups" {
  source = "./modules/security_groups"
  cluster_name = "${var.cluster["name"]}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
  vpc_id = "${module.vpc.vpc_id}"
}

module "vpc" {
  source = "./modules/vpc"
  cidr_block = "${var.vpc_cidr_block}"
  cluster_name = "${var.cluster["name"]}"
  region = "${var.aws_region}"
  subnets = ["${var.subnets}"]
}

resource "aws_key_pair" "key_pair" {
  key_name = "${var.cluster["name"]}"
  public_key = "${file(format("keys/%s.pub", var.cluster["name"]))}"
}
