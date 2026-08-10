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
