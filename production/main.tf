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

module "eks_cluster" {
  source = "../modules/eks-cluster"

  cluster_name         = local.cluster_name
  eks_version          = "1.36"
  coredns_version      = "v1.14.3-eksbuild.3"
  kube_proxy_version   = "v1.36.0-eksbuild.13"
  vpc_cni_version      = "v1.22.3-eksbuild.1"
  ebs_csi_version      = "v1.63.1-eksbuild.1"
  pod_identity_version = "v1.3.10-eksbuild.3"

  vpc_id             = module.networks.vpc_id
  private_subnet_ids = module.networks.private_subnets

  sso_admin_role_arn = "arn:aws:iam::522783511350:role/aws-reserved/sso.amazonaws.com/ap-southeast-3/AWSReservedSSO_AdministratorAccess_bec8d2bbd660c382"

  default_tags = var.default_tags
}

module "efs" {
  source = "../modules/efs"

  cluster_name           = module.eks_cluster.cluster_name
  vpc_id                 = module.networks.vpc_id
  subnet_ids             = module.networks.private_subnets
  node_security_group_id = module.eks_cluster.node_security_group_id
  backup_enabled         = false
  default_tags           = var.default_tags
}

module "karpenter" {
  source = "../modules/karpenter"

  cluster_name     = module.eks_cluster.cluster_name
  cluster_endpoint = module.eks_cluster.cluster_endpoint
  default_tags     = var.default_tags
}

module "cluster_addons" {
  source = "../modules/cluster-addons"

  cluster_name = module.eks_cluster.cluster_name
  environment  = var.environment
  aws_region   = var.aws_region

  external_dns_target_role_arn = "arn:aws:iam::686410905891:role/externaldns-pod-identity-target-role-production"
  external_dns_domain_filters  = ["piksel.big.go.id"]
  external_dns_zone_id_filters = ["Z08561162REF6LC5AY0UM"]

  acme_email = "piksel@big.go.id"

  default_tags = var.default_tags

  depends_on = [module.karpenter]
}

module "rds" {
  source = "../modules/rds"

  project             = var.project
  environment         = var.environment
  cluster_name        = module.eks_cluster.cluster_name
  vpc_id              = module.networks.vpc_id
  vpc_cidr_block      = module.networks.vpc_cidr_block
  private_subnets_ids = module.networks.private_subnets

  pg_host = var.pg_host
  pg_port = var.pg_port

  default_tags = var.default_tags
}

module "applications" {
  source = "../modules/applications"

  providers = {
    aws.virginia      = aws.virginia
    aws.cross_account = aws.cross_account
  }

  project      = var.project
  environment  = var.environment
  aws_region   = var.aws_region
  default_tags = var.default_tags

  account_id   = module.networks.account_id
  cluster_name = module.eks_cluster.cluster_name

  subdomains                           = local.subdomains
  public_hosted_zone_id                = local.public_hosted_zone_id
  cognito_auth_domain                  = local.cognito_auth_domain
  odc_cloudfront_crossaccount_role_arn = local.odc_cloudfront_crossaccount_role_arn

  internal_buckets           = [module.buckets.public_data_bucket_name]
  read_external_buckets      = local.read_external_buckets
  public_bucket_arn          = module.buckets.public_data_bucket_arn
  argo_artifacts_bucket_name = module.buckets.argo_artifacts_bucket_name
  terria_bucket_name         = module.buckets.terria_bucket_name

  db_namespace      = module.rds.db_namespace
  db_address        = module.rds.db_address
  k8s_db_service    = module.rds.k8s_db_service
  db_user_passwords = module.rds.user_passwords

  waf_log_retention_days = 365
  enable_grafana         = true
}
