variable "assets_bucket_name" {}
variable "availability_zone" {}
variable "cluster" { type = "map" }
variable "controller_endpoint" {}
variable "coreos_channel" { default = "stable" }
variable "hyperkube" { type = "map" }
variable "instance_profile" {}
variable "instance_type" {}
variable "internal_domain_name" {}
variable "max_pool_size" { default = 64 }
variable "min_pool_size" { default = 2 }
variable "security_groups" { type = "list" }
variable "spot_price" { default = "" }
variable "ssh_key_name" {}
variable "subnet_id" {}
variable "volume_size" { default = 32 }
variable "volume_type" { default = "gp2" }
