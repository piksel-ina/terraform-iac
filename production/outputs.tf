output "network_metadata" {
  description = "Grouped network and connectivity metadata"
  value = {
    account_id      = module.networks.account_id
    vpc_id          = module.networks.vpc_id
    vpc_cidr_block  = module.networks.vpc_cidr_block
    azs             = module.networks.azs
    public_subnets  = module.networks.public_subnets
    private_subnets = module.networks.private_subnets
    nat_public_ips  = module.networks.nat_public_ips
  }
}
