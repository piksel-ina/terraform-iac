module "networks" {
  source = "../modules/networks"

  project      = var.project
  environment  = var.environment
  aws_region   = var.aws_region
  cluster_name = local.cluster_name
  vpc_cidr     = "10.3.0.0/16"
  az_count     = 3
  default_tags = var.default_tags
}

module "buckets" {
  source = "../modules/s3-bucket"

  project               = var.project
  environment           = var.environment
  default_tags          = var.default_tags
  create_iac_state      = true
  create_public_data    = true
  create_argo_artifacts = true
  create_terria         = true
}
