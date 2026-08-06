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

output "buckets" {
  description = "Provisioned S3 bucket names and ARNs"
  value = {
    iac_state      = { name = module.buckets.iac_state_bucket_name, arn = module.buckets.iac_state_bucket_arn }
    public_data    = { name = module.buckets.public_data_bucket_name, arn = module.buckets.public_data_bucket_arn }
    argo_artifacts = { name = module.buckets.argo_artifacts_bucket_name, arn = module.buckets.argo_artifacts_bucket_arn }
    terria         = { name = module.buckets.terria_bucket_name, arn = module.buckets.terria_bucket_arn }
  }
}
