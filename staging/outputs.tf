output "account_id" {
  description = "The AWS account ID"
  value       = module.networks.account_id
}

output "network_metadata" {
  description = "Grouped network and connectivity metadata"
  value = {
    vpc = {
      id                               = module.networks.vpc_id
      cidr_block                       = module.networks.vpc_cidr_block
      flow_log_id                      = module.networks.vpc_flow_log_id
      flow_log_cloudwatch_iam_role_arn = module.networks.vpc_flow_log_cloudwatch_iam_role_arn
    }
    subnets = {
      public_ids                = module.networks.public_subnets
      public_cidr_blocks        = module.networks.public_subnets_cidr_blocks
      private_ids               = module.networks.private_subnets
      private_cidr_blocks       = module.networks.private_subnets_cidr_blocks
      public_large_subnet_ids   = module.networks.public_large_subnet_ids
      public_large_subnet_cidrs = module.networks.public_large_subnet_cidrs
    }
    nat = {
      ids        = module.networks.natgw_ids
      public_ips = module.networks.nat_public_ips
    }
    route_tables = {
      public_ids  = module.networks.public_route_table_ids
      private_ids = module.networks.private_route_table_ids
    }
  }
}

output "eks_cluster_metadata" {
  description = "Output of EKS Cluster"
  value = {
    name            = module.eks_cluster.cluster_name
    endpoint        = module.eks_cluster.cluster_endpoint
    oidc_issuer_url = module.eks_cluster.cluster_oidc_issuer_url
  }
}

output "efs_metadata" {
  description = "Output of EFS filesystem and security group"
  value = {
    filesystem_id     = module.efs.filesystem_id
    security_group_id = module.efs.security_group_id
  }
}

# --- Karpenter Outputs ---
output "karpenter_metadata" {
  description = "Output of Karpenter configuration and resources"
  value = {
    controller_iam_role_arn = module.karpenter.controller_iam_role_arn
    node_iam_role_name      = module.karpenter.node_iam_role_name
    interruption_queue_name = module.karpenter.interruption_queue_name
    helm_release_status     = module.karpenter.helm_release_status
  }
}

# --- Public S3 Bucket ---
output "s3_public_metadata" {
  description = "Output of S3 bucket"
  value = {
    name           = module.s3_bucket.public_data_bucket_name
    arn            = module.s3_bucket.public_data_bucket_arn
    argo_artifacts = module.s3_bucket.argo_artifacts_bucket_name
    terria         = module.s3_bucket.terria_bucket_name
  }
}

# --- Database outputs ---
output "database_metadata" {
  description = "Output of RDS database configuration and resources"
  sensitive   = true

  value = {
    endpoint          = module.rds.db_endpoint
    address           = module.rds.db_address
    port              = module.rds.db_port
    instance_id       = module.rds.db_instance_id
    k8s_service_fqdn  = module.rds.k8s_db_service
    k8s_namespace     = module.rds.db_namespace
    database_name     = module.rds.db_name
    db_username       = module.rds.db_username
    security_group_id = module.rds.security_group_id
  }
}


# --- Cluster Addons ---
output "cluster_addons_metadata" {
  description = "Cluster addon Helm release statuses"
  value = {
    cert-manager   = module.cluster_addons.cert_manager_status
    ingress-nginx  = module.cluster_addons.ingress_nginx_status
    metrics-server = module.cluster_addons.metrics_server_status
    external-dns   = module.cluster_addons.external_dns_status
  }
}

# --- Applications ---
output "applications_metadata" {
  description = "Output of applications module"
  value = {
    odc_namespace             = module.applications.odc_namespace
    ows_cache_cloudfront      = module.applications.ows_cache_cloudfront_domain_name
    ows_cache_distribution_id = module.applications.ows_cache_cloudfront_distribution_id
    stac_namespace            = module.applications.stac_namespace
    argo_workflow_namespace   = module.applications.argo_workflow_namespace
    jupyterhub_namespace      = module.applications.jupyterhub_namespace
    terria_namespace          = module.applications.terria_namespace
  }
}

output "github_tf_deploy_role_arn" {
  description = "ARN of the IAM role for GitHub Actions Terraform deployment (OIDC)"
  value       = aws_iam_role.github_tf_deploy.arn
}

output "codebuild_metadata" {
  description = "CodeBuild project details for Terraform CI/CD"
  value = {
    plan_project_name  = module.codebuild.plan_project_name
    apply_project_name = module.codebuild.apply_project_name
    codebuild_role_arn = module.codebuild.codebuild_role_arn
  }
}
