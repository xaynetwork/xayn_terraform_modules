locals {
  all_ips           = "0.0.0.0/0"
  priv_subnet_count = length(var.private_subnets)
  pub_subnet_count  = length(var.public_subnets)
}
