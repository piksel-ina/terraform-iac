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
