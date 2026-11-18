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
  source = "../modules/s3-bucket"

  project               = var.project
  environment           = var.environment
  create_public_data    = true
  create_argo_artifacts = true
  create_terria         = true
  default_tags          = var.default_tags
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  tags = merge(var.default_tags, { ManagedBy = "Terraform" })
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
          "token.actions.githubusercontent.com:sub" = "repo:piksel-ina/terraform-iac:ref:refs/heads/main"
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

resource "aws_iam_role" "github_tf_plan" {
  name = "piksel-tf-plan-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:piksel-ina/terraform-iac:pull_request"
        }
      }
    }]
  })

  tags = merge(var.default_tags, { ManagedBy = "Terraform" })
}

resource "aws_iam_policy" "github_tf_plan" {
  name = "piksel-tf-plan-github-actions-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"]
        Resource = [module.codebuild.plan_project_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["logs:GetLogEvents"]
        Resource = [module.codebuild.plan_log_group_arn]
      }
    ]
  })

  tags = merge(var.default_tags, { ManagedBy = "Terraform" })
}

resource "aws_iam_role_policy_attachment" "github_tf_plan" {
  role       = aws_iam_role.github_tf_plan.name
  policy_arn = aws_iam_policy.github_tf_plan.arn
}

module "rds" {
  source = "../modules/rds"

  project                 = var.project
  environment             = var.environment
  vpc_id                  = module.networks.vpc_id
  vpc_cidr_block          = module.networks.vpc_cidr_block
  private_subnets_ids     = module.networks.private_subnets
  cluster_name            = module.eks_cluster.cluster_name
  default_tags            = var.default_tags
  engine_version          = "17.9"
  instance_class          = "db.t4g.large"
  allocated_storage       = 50
  max_allocated_storage   = 0
  backup_retention_period = 14
  multi_az                = false
  pg_host                 = var.pg_host
  pg_port                 = var.pg_port
}

module "eks_cluster" {
  source = "../modules/eks-cluster"

  cluster_name         = local.cluster_name
  eks_version          = "1.34"
  coredns_version      = "v1.13.2-eksbuild.4"
  vpc_cni_version      = "v1.21.1-eksbuild.7"
  kube_proxy_version   = "v1.34.6-eksbuild.2"
  ebs_csi_version      = "v1.57.1-eksbuild.1"
  pod_identity_version = "v1.3.10-eksbuild.2"

  vpc_id             = module.networks.vpc_id
  private_subnet_ids = module.networks.private_subnets

  sso_admin_role_arn = "arn:aws:iam::326641642924:role/aws-reserved/sso.amazonaws.com/ap-southeast-3/AWSReservedSSO_AdministratorAccess_0e029b26d9443921"

  additional_access_entries = {
    codebuild = {
      principal_arn = module.codebuild.codebuild_role_arn
    }
  }

  efs_backup_enabled = false
  default_tags       = var.default_tags
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

  cluster_name              = module.eks_cluster.cluster_name
  cluster_endpoint          = module.eks_cluster.cluster_endpoint
  default_ami_alias         = "al2023@v20260403"
  gpu_ami_name              = "amazon-eks-node-al2023-x86_64-nvidia-1.34-v20260403"
  data_production_cpu_limit = 450
  gpu_nodepool_limit        = 20
  default_tags              = var.default_tags
}

module "cluster_addons" {
  source = "../modules/cluster-addons"

  cluster_name = module.eks_cluster.cluster_name
  environment  = var.environment
  aws_region   = var.aws_region

  external_dns_target_role_arn = "arn:aws:iam::686410905891:role/externaldns-pod-identity-target-role-staging"
  external_dns_domain_filters  = local.subdomains
  external_dns_zone_id_filters = ["Z00431943HAESMJJNQCQR"]

  acme_email   = "piksel@big.go.id"
  default_tags = var.default_tags

  depends_on = [module.karpenter]
}

module "codebuild" {
  source = "../modules/codebuild"

  project             = var.project
  environment         = var.environment
  aws_region          = var.aws_region
  account_id          = module.networks.account_id
  vpc_id              = module.networks.vpc_id
  vpc_cidr_block      = module.networks.vpc_cidr_block
  private_subnet_ids  = module.networks.private_subnets
  tf_working_dir      = "staging"
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
  security_group_id        = module.eks_cluster.cluster_security_group_id
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
  public_hosted_zone_id                = "Z00431943HAESMJJNQCQR"
  cognito_auth_domain                  = "oauth.piksel.big.go.id"
  odc_cloudfront_crossaccount_role_arn = "arn:aws:iam::686410905891:role/odc-cloudfront-crossaccount-role-staging"

  internal_buckets           = [module.s3_bucket.public_data_bucket_name]
  public_bucket_arn          = module.s3_bucket.public_data_bucket_arn
  argo_artifacts_bucket_name = module.s3_bucket.argo_artifacts_bucket_name
  terria_bucket_name         = module.s3_bucket.terria_bucket_name
  read_external_buckets = [
    "usgs-landsat",
    "copernicus-dem-30m",
    "e84-earth-search-sentinel-data"
  ]

  db_namespace      = module.rds.db_namespace
  db_address        = module.rds.db_address
  k8s_db_service    = module.rds.k8s_db_service
  db_user_passwords = module.rds.user_passwords

  waf_log_retention_days = 30
  enable_grafana         = false
}
