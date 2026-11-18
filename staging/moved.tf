moved {
  from = module.database.module.db
  to   = module.rds.module.db
}

moved {
  from = module.database.module.security_group
  to   = module.rds.module.security_group
}

moved {
  from = module.database.random_password.db_random_string
  to   = module.rds.random_password.master
}

moved {
  from = module.database.aws_secretsmanager_secret.db_password
  to   = module.rds.aws_secretsmanager_secret.master
}

moved {
  from = module.database.aws_secretsmanager_secret_version.db_password
  to   = module.rds.aws_secretsmanager_secret_version.master
}

moved {
  from = module.database.kubernetes_namespace.db
  to   = module.rds.kubernetes_namespace.db
}

moved {
  from = module.database.kubernetes_secret.db_password
  to   = module.rds.kubernetes_secret.master
}

moved {
  from = module.database.kubernetes_service.db_endpoint
  to   = module.rds.kubernetes_service.db_endpoint
}

moved {
  from = module.database.random_password.argo
  to   = module.rds.random_password.app_users["argo"]
}

moved {
  from = module.database.random_password.grafana
  to   = module.rds.random_password.app_users["grafana"]
}

moved {
  from = module.database.random_password.jupyterhub
  to   = module.rds.random_password.app_users["jupyterhub"]
}

moved {
  from = module.database.random_password.odc_write
  to   = module.rds.random_password.app_users["odc"]
}

moved {
  from = module.database.random_password.odc_read
  to   = module.rds.random_password.app_users["odcread"]
}

moved {
  from = module.database.random_password.stac_write
  to   = module.rds.random_password.app_users["stac"]
}

moved {
  from = module.database.random_password.stac_read
  to   = module.rds.random_password.app_users["stacread"]
}

moved {
  from = module.database.aws_secretsmanager_secret.argo_password
  to   = module.rds.aws_secretsmanager_secret.app_users["argo"]
}

moved {
  from = module.database.aws_secretsmanager_secret.grafana_password
  to   = module.rds.aws_secretsmanager_secret.app_users["grafana"]
}

moved {
  from = module.database.aws_secretsmanager_secret.jupyterhub_password
  to   = module.rds.aws_secretsmanager_secret.app_users["jupyterhub"]
}

moved {
  from = module.database.aws_secretsmanager_secret.odc_write_password
  to   = module.rds.aws_secretsmanager_secret.app_users["odc"]
}

moved {
  from = module.database.aws_secretsmanager_secret.odc_read_password
  to   = module.rds.aws_secretsmanager_secret.app_users["odcread"]
}

moved {
  from = module.database.aws_secretsmanager_secret.stac_write_password
  to   = module.rds.aws_secretsmanager_secret.app_users["stac"]
}

moved {
  from = module.database.aws_secretsmanager_secret.stacread_password
  to   = module.rds.aws_secretsmanager_secret.app_users["stacread"]
}

moved {
  from = module.database.aws_secretsmanager_secret_version.argo_password
  to   = module.rds.aws_secretsmanager_secret_version.app_users["argo"]
}

moved {
  from = module.database.aws_secretsmanager_secret_version.grafana_password
  to   = module.rds.aws_secretsmanager_secret_version.app_users["grafana"]
}

moved {
  from = module.database.aws_secretsmanager_secret_version.jupyterhub_password
  to   = module.rds.aws_secretsmanager_secret_version.app_users["jupyterhub"]
}

moved {
  from = module.database.aws_secretsmanager_secret_version.odc_write_password
  to   = module.rds.aws_secretsmanager_secret_version.app_users["odc"]
}

moved {
  from = module.database.aws_secretsmanager_secret_version.odc_read_password
  to   = module.rds.aws_secretsmanager_secret_version.app_users["odcread"]
}

moved {
  from = module.database.aws_secretsmanager_secret_version.stac_write_password
  to   = module.rds.aws_secretsmanager_secret_version.app_users["stac"]
}

moved {
  from = module.database.aws_secretsmanager_secret_version.stacread_password
  to   = module.rds.aws_secretsmanager_secret_version.app_users["stacread"]
}

moved {
  from = module.database.postgresql_extension.postgis
  to   = module.rds.postgresql_extension.postgis_odc
}

moved {
  from = module.database.postgresql_extension.postgis_stac
  to   = module.rds.postgresql_extension.postgis_stac
}

moved {
  from = module.database.postgresql_database.app_databases
  to   = module.rds.postgresql_database.app_databases
}

moved {
  from = module.database.postgresql_role.app_users
  to   = module.rds.postgresql_role.app_users
}

moved {
  from = module.database.postgresql_grant.database_connect
  to   = module.rds.postgresql_grant.database_connect
}

moved {
  from = module.database.postgresql_grant.schema_usage
  to   = module.rds.postgresql_grant.schema_usage
}

moved {
  from = module.database.postgresql_grant.full_table_permissions
  to   = module.rds.postgresql_grant.full_table_permissions
}

moved {
  from = module.database.postgresql_grant.full_sequence_permissions
  to   = module.rds.postgresql_grant.full_sequence_permissions
}

moved {
  from = module.database.postgresql_grant.readonly_table_permissions
  to   = module.rds.postgresql_grant.readonly_table_permissions
}

moved {
  from = module.database.postgresql_grant.readonly_sequence_permissions
  to   = module.rds.postgresql_grant.readonly_sequence_permissions
}

moved {
  from = module.database.postgresql_grant.grafana_table_permissions
  to   = module.rds.postgresql_grant.grafana_table_permissions
}

moved {
  from = module.database.postgresql_grant.grafana_sequence_permissions
  to   = module.rds.postgresql_grant.grafana_sequence_permissions
}

moved {
  from = module.database.postgresql_default_privileges.full_table_defaults
  to   = module.rds.postgresql_default_privileges.full_table_defaults
}

moved {
  from = module.database.postgresql_default_privileges.full_sequence_defaults
  to   = module.rds.postgresql_default_privileges.full_sequence_defaults
}

moved {
  from = module.database.postgresql_default_privileges.readonly_table_defaults
  to   = module.rds.postgresql_default_privileges.readonly_table_defaults
}

moved {
  from = module.database.postgresql_default_privileges.readonly_sequence_defaults
  to   = module.rds.postgresql_default_privileges.readonly_sequence_defaults
}

moved {
  from = module.database.postgresql_default_privileges.grafana_table_defaults
  to   = module.rds.postgresql_default_privileges.grafana_table_defaults
}

moved {
  from = module.database.postgresql_default_privileges.grafana_sequence_defaults
  to   = module.rds.postgresql_default_privileges.grafana_sequence_defaults
}

# --- EKS Cluster & EFS ---
moved {
  from = module.eks-cluster.module.eks
  to   = module.eks_cluster.module.eks
}

moved {
  from = module.eks-cluster.aws_iam_policy.assume_ecr_role
  to   = module.eks_cluster.aws_iam_policy.assume_ecr_role
}

moved {
  from = module.cluster-addons.kubectl_manifest.gp3_storageclass
  to   = module.eks_cluster.kubectl_manifest.gp3
}

moved {
  from = module.eks-cluster.aws_security_group.efs
  to   = module.efs.aws_security_group.efs
}

moved {
  from = module.eks-cluster.aws_security_group_rule.efs_ingress_nodes
  to   = module.efs.aws_security_group_rule.efs_ingress_nodes
}

moved {
  from = module.eks-cluster.aws_security_group_rule.efs_egress_all
  to   = module.efs.aws_security_group_rule.efs_egress_all
}

moved {
  from = module.eks-cluster.aws_efs_file_system.data
  to   = module.efs.aws_efs_file_system.data
}

moved {
  from = module.eks-cluster.aws_efs_mount_target.data
  to   = module.efs.aws_efs_mount_target.data
}

moved {
  from = module.eks-cluster.aws_efs_backup_policy.data
  to   = module.efs.aws_efs_backup_policy.data
}

moved {
  from = module.cluster-addons.helm_release.aws_efs_csi_driver
  to   = module.efs.helm_release.csi_driver
}

# --- Karpenter ---
moved {
  from = module.karpenter.module.karpenter
  to   = module.karpenter.module.controller
}

moved {
  from = module.karpenter.aws_iam_role_policy.karpenter_node_ecr_cross_account
  to   = module.karpenter.aws_iam_role_policy.node_ecr_cross_account
}

moved {
  from = module.karpenter.time_sleep.wait_for_karpenter
  to   = module.karpenter.time_sleep.wait_for_karpenter_crds
}

# --- Cluster Addons & External DNS ---
moved {
  from = module.cluster-addons.kubernetes_namespace.cert_manager
  to   = module.cluster_addons.kubernetes_namespace.cert_manager
}

moved {
  from = module.cluster-addons.kubernetes_namespace.ingress_nginx
  to   = module.cluster_addons.kubernetes_namespace.ingress_nginx
}

moved {
  from = module.cluster-addons.helm_release.cert_manager
  to   = module.cluster_addons.helm_release.cert_manager
}

moved {
  from = module.cluster-addons.helm_release.ingress_nginx
  to   = module.cluster_addons.helm_release.ingress_nginx
}

moved {
  from = module.cluster-addons.helm_release.metrics_server
  to   = module.cluster_addons.helm_release.metrics_server
}

moved {
  from = module.cluster-addons.kubectl_manifest.letsencrypt_production
  to   = module.cluster_addons.kubectl_manifest.letsencrypt_production
}

moved {
  from = module.cluster-addons.kubectl_manifest.letsencrypt_staging
  to   = module.cluster_addons.kubectl_manifest.letsencrypt_staging
}

moved {
  from = module.external-dns.kubernetes_namespace.external_dns
  to   = module.cluster_addons.kubernetes_namespace.external_dns
}

moved {
  from = module.external-dns.aws_iam_role.external_dns
  to   = module.cluster_addons.aws_iam_role.external_dns
}

moved {
  from = module.external-dns.aws_iam_role_policy.external_dns
  to   = module.cluster_addons.aws_iam_role_policy.external_dns
}

moved {
  from = module.external-dns.helm_release.external_dns
  to   = module.cluster_addons.helm_release.external_dns
}

# --- Applications (preserve stateful/CloudFront/ACM/WAF/secrets) ---
moved {
  from = module.applications.aws_acm_certificate.ows_cache
  to   = module.applications.aws_acm_certificate.ows_cache
}

moved {
  from = module.applications.aws_route53_record.ows_certificate
  to   = module.applications.aws_route53_record.ows_certificate
}

moved {
  from = module.applications.aws_acm_certificate_validation.ows_certificate
  to   = module.applications.aws_acm_certificate_validation.ows_certificate
}

moved {
  from = module.applications.aws_wafv2_web_acl.ows_cache
  to   = module.applications.aws_wafv2_web_acl.ows_cache
}

moved {
  from = module.applications.aws_cloudwatch_log_group.waf_logs
  to   = module.applications.aws_cloudwatch_log_group.waf_logs
}

moved {
  from = module.applications.aws_cloudwatch_log_resource_policy.waf_logs
  to   = module.applications.aws_cloudwatch_log_resource_policy.waf_logs
}

moved {
  from = module.applications.aws_wafv2_web_acl_logging_configuration.ows_cache
  to   = module.applications.aws_wafv2_web_acl_logging_configuration.ows_cache
}

moved {
  from = module.applications.aws_cloudfront_distribution.ows_cache
  to   = module.applications.aws_cloudfront_distribution.ows_cache
}

moved {
  from = module.applications.aws_route53_record.ows_cache
  to   = module.applications.aws_route53_record.ows_cache
}

moved {
  from = module.applications.aws_cloudfront_response_headers_policy.ows_cors
  to   = module.applications.aws_cloudfront_response_headers_policy.ows_cors
}

moved {
  from = module.applications.random_password.ows_origin
  to   = module.applications.random_password.ows_origin
}

moved {
  from = module.applications.random_id.jhub_hub_cookie_secret_token
  to   = module.applications.random_id.jhub_hub_cookie_secret_token
}

moved {
  from = module.applications.random_id.jhub_proxy_secret_token
  to   = module.applications.random_id.jhub_proxy_secret_token
}

moved {
  from = module.applications.random_password.dask_gateway_api_token
  to   = module.applications.random_password.dask_gateway_api_token
}
