locals {
  cluster_name = "piksel-staging"
  subdomains   = ["staging.piksel.big.go.id"]
}

module "networks" {
  source = "../networks"

  project      = var.project
  environment  = var.environment
  cluster_name = local.cluster_name
  vpc_cidr     = "10.2.0.0/16"
  az_count     = "2"
  default_tags = var.default_tags
}


module "s3_bucket" {
  source = "../aws-s3-bucket"

  project                   = var.project
  environment               = var.environment
  default_tags              = var.default_tags
  lifecycle_expiration_days = 365
}

module "website" {
  source = "../aws-s3-static-hosting"

  providers = {
    aws     = aws.aws
    aws.dns = aws.cross_account
  }

  project        = var.project
  environment    = var.environment
  domain_name    = "staging.piksel.big.go.id"
  hosted_zone_id = "Z00431943HAESMJJNQCQR"
  default_tags   = var.default_tags
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  tags = merge(var.default_tags, { ManagedBy = "Terraform" })
}

resource "aws_iam_role" "github_website_deploy" {
  name = "piksel-website-deploy-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:piksel-ina/main-website:*"
        }
      }
    }]
  })

  tags = merge(var.default_tags, { ManagedBy = "Terraform" })
}

resource "aws_iam_policy" "github_website_deploy" {
  name = "piksel-website-deploy-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [module.website.bucket_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = ["${module.website.bucket_arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = ["arn:aws:cloudfront::326641642924:distribution/${module.website.cloudfront_distribution_id}"]
      }
    ]
  })

  tags = merge(var.default_tags, { ManagedBy = "Terraform" })
}

resource "aws_iam_role_policy_attachment" "github_website_deploy" {
  role       = aws_iam_role.github_website_deploy.name
  policy_arn = aws_iam_policy.github_website_deploy.arn
}

resource "aws_iam_role" "github_tf_deploy" {
  name = "piksel-tf-deploy-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:piksel-ina/terraform-iac:*"
        }
      }
    }]
  })

  tags = merge(var.default_tags, { ManagedBy = "Terraform" })
}

resource "aws_iam_policy" "github_tf_deploy" {
  name = "piksel-tf-deploy-github-actions-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]
        Resource = [
          module.codebuild.plan_project_arn,
          module.codebuild.apply_project_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:GetLogEvents"
        ]
        Resource = [
          module.codebuild.plan_log_group_arn,
          module.codebuild.apply_log_group_arn
        ]
      }
    ]
  })

  tags = merge(var.default_tags, { ManagedBy = "Terraform" })
}

resource "aws_iam_role_policy_attachment" "github_tf_deploy" {
  role       = aws_iam_role.github_tf_deploy.name
  policy_arn = aws_iam_policy.github_tf_deploy.arn
}

module "database" {
  source = "../aws-database"

  project                 = var.project
  environment             = var.environment
  vpc_id                  = module.networks.vpc_id
  vpc_cidr_block          = module.networks.vpc_cidr_block
  private_subnets_ids     = module.networks.private_subnets
  cluster_name            = module.eks-cluster.cluster_name
  default_tags            = var.default_tags
  db_instance_class       = "db.t4g.large"
  db_allocated_storage    = 50
  backup_retention_period = 14
  db_multi_az             = false
  pg_host                 = var.pg_host
  pg_port                 = var.pg_port
}

module "eks-cluster" {
  source = "../aws-eks-cluster"

  account_id           = module.networks.account_id
  cluster_name         = local.cluster_name
  vpc_id               = module.networks.vpc_id
  vpc_cidr_block       = module.networks.vpc_cidr_block
  private_subnets_ids  = module.networks.private_subnets
  eks-version          = "1.34"
  coredns-version      = "v1.13.2-eksbuild.4"
  vpc-cni-version      = "v1.21.1-eksbuild.7"
  kube-proxy-version   = "v1.34.6-eksbuild.2"
  ebs-csi-version      = "v1.57.1-eksbuild.1"
  pod-identity-version = "v1.3.10-eksbuild.2"
  sso-admin-role-arn   = "arn:aws:iam::326641642924:role/aws-reserved/sso.amazonaws.com/ap-southeast-3/AWSReservedSSO_AdministratorAccess_0e029b26d9443921"
  codebuild_role_arn   = module.codebuild.codebuild_role_arn
  efs_backup_enabled   = false
  default_tags         = var.default_tags
}

module "external-dns" {
  source = "../external-dns"

  aws_region                        = var.aws_region
  project                           = var.project
  environment                       = var.environment
  cluster_name                      = local.cluster_name
  subdomains                        = local.subdomains
  oidc_provider                     = module.eks-cluster.cluster_oidc_issuer_url
  oidc_provider_arn                 = module.eks-cluster.cluster_oidc_provider_arn
  externaldns_crossaccount_role_arn = "arn:aws:iam::686410905891:role/externaldns-crossaccount-role-staging"
  default_tags                      = var.default_tags
}

module "karpenter" {
  source = "../karpenter"

  cluster_name                = local.cluster_name
  oidc_provider_arn           = module.eks-cluster.cluster_oidc_provider_arn
  cluster_endpoint            = module.eks-cluster.cluster_endpoint
  default_nodepool_ami_alias  = "al2023@v20260403"
  default_nodepool_node_limit = 10000
  data_production_cpu_limit   = 450
  gpu_nodepool_ami            = "amazon-eks-node-al2023-x86_64-nvidia-1.34-v20260403"
  gpu_nodepool_node_limit     = 20
  default_tags                = var.default_tags
}

module "cluster-addons" {
  source = "../cluster-addons"

  cluster_name          = local.cluster_name
  efs_filesystem_id     = module.eks-cluster.efs_filesystem_id
  efs_csi_irsa_role_arn = module.eks-cluster.efs_csi_irsa_role_arn
  aws_region            = var.aws_region
  default_tags          = var.default_tags
}

module "codebuild" {
  source = "../codebuild"

  project             = var.project
  environment         = var.environment
  aws_region          = var.aws_region
  account_id          = module.networks.account_id
  vpc_id              = module.networks.vpc_id
  vpc_cidr_block      = module.networks.vpc_cidr_block
  private_subnet_ids  = module.networks.private_subnets
  cluster_name        = local.cluster_name
  tf_state_bucket_arn = "arn:aws:s3:::piksel-staging-tfstate"
  default_tags        = var.default_tags
}

resource "aws_security_group_rule" "codebuild_to_eks_api" {
  description              = "Allow CodeBuild to reach EKS control plane API"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = module.codebuild.codebuild_security_group_id
  security_group_id        = module.eks-cluster.cluster_security_group_id
}

module "applications" {
  source = "../applications"

  account_id                           = module.networks.account_id
  project                              = var.project
  environment                          = var.environment
  cluster_name                         = module.eks-cluster.cluster_name
  default_tags                         = var.default_tags
  eks_oidc_provider_arn                = module.eks-cluster.cluster_oidc_provider_arn
  oidc_issuer_url                      = module.eks-cluster.cluster_oidc_issuer_url
  db_namespace                         = module.database.db_namespace
  db_address                           = module.database.db_address
  k8s_db_service                       = module.database.k8s_db_service
  subdomains                           = local.subdomains
  public_hosted_zone_id                = "Z00431943HAESMJJNQCQR"
  oauth_tenant                         = "oauth.piksel.big.go.id"
  internal_buckets                     = [module.s3_bucket.public_bucket_name]
  odc_cloudfront_crossaccount_role_arn = "arn:aws:iam::686410905891:role/odc-cloudfront-crossaccount-role-staging"
  public_bucket_arn                    = module.s3_bucket.public_bucket_arn
  read_external_buckets = [
    "usgs-landsat",
    "copernicus-dem-30m",
    "e84-earth-search-sentinel-data"
  ]
  waf_log_retention_days    = 30
  lifecycle_expiration_days = 60
  enable_grafana            = false

  argo_password       = module.database.user_passwords.argo
  grafana_password    = module.database.user_passwords.grafana
  jupyterhub_password = module.database.user_passwords.jupyterhub
  odc_write_password  = module.database.user_passwords.odc
  odc_read_password   = module.database.user_passwords.odcread
  stac_write_password = module.database.user_passwords.stac
  stac_read_password  = module.database.user_passwords.stacread
}
