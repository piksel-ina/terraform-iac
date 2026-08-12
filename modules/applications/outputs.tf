# --- Monitoring / Grafana ---
output "grafana_namespace" {
  description = "Kubernetes namespace where monitoring resources are deployed."
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_iam_role_arn" {
  description = "IAM role ARN used by Grafana via Pod Identity. Empty when Grafana is disabled."
  value       = var.enable_grafana ? aws_iam_role.grafana[0].arn : ""
}

output "grafana_cloudwatch_policy_arn" {
  description = "IAM policy ARN granting Grafana CloudWatch access. Empty when Grafana is disabled."
  value       = var.enable_grafana ? aws_iam_policy.grafana_cloudwatch[0].arn : ""
}

output "grafana_admin_secret_name" {
  description = "Name of the Kubernetes secret storing the Grafana admin credentials. Empty when Grafana is disabled."
  value       = var.enable_grafana ? kubernetes_secret.grafana_admin_credentials[0].metadata[0].name : ""
}

output "grafana_values_secret_name" {
  description = "Name of the Kubernetes secret containing the Grafana Helm values. Empty when Grafana is disabled."
  value       = var.enable_grafana ? kubernetes_secret.grafana_values[0].metadata[0].name : ""
}

# --- JupyterHub ---
output "jupyterhub_namespace" {
  description = "Namespace where JupyterHub is deployed."
  value       = kubernetes_namespace.hub.metadata[0].name
}

output "jupyterhub_subdomain" {
  description = "Public subdomain for JupyterHub."
  value       = local.jhub_subdomain
}

output "jupyterhub_role_arn" {
  description = "IAM role ARN for the JupyterHub user-read service account (Pod Identity)."
  value       = aws_iam_role.hub_user_read.arn
}

output "jupyterhub_service_account_name" {
  description = "Service account name bound to the JupyterHub user-read role."
  value       = kubernetes_service_account.hub_user_read.metadata[0].name
}

# --- Argo Workflows ---
output "argo_workflow_namespace" {
  description = "Namespace for all Argo resources."
  value       = kubernetes_namespace.argo_workflow.metadata[0].name
}

output "argo_workflow_role_arn" {
  description = "IAM role ARN bound to the Argo executor and server service accounts (Pod Identity)."
  value       = aws_iam_role.argo_workflow.arn
}

output "argo_artifact_policy_arn" {
  description = "IAM policy ARN granting read/write access to the Argo artifacts bucket."
  value       = aws_iam_policy.argo_artifact_read_write.arn
}

output "argo_client_secret_name" {
  description = "Kubernetes secret holding the Argo Cognito OAuth client credentials."
  value       = kubernetes_secret.argo_server_sso.metadata[0].name
}

# --- ODC / OWS ---
output "odc_namespace" {
  description = "Kubernetes namespace for ODC."
  value       = kubernetes_namespace.odc.metadata[0].name
}

output "odc_data_reader_role_arn" {
  description = "IAM role ARN for the ODC data reader (Pod Identity)."
  value       = aws_iam_role.odc_data_reader.arn
}

output "ows_cache_cloudfront_domain_name" {
  description = "CloudFront distribution domain name for the OWS cache."
  value       = aws_cloudfront_distribution.ows_cache.domain_name
}

output "ows_cache_cloudfront_distribution_id" {
  description = "CloudFront distribution ID for the OWS cache."
  value       = aws_cloudfront_distribution.ows_cache.id
}

output "ows_cache_certificate_arn" {
  description = "ACM certificate ARN for the OWS cache."
  value       = aws_acm_certificate.ows_cache.arn
}

output "ows_cache_dns_record" {
  description = "FQDN of the Route53 record for the OWS cache."
  value       = aws_route53_record.ows_cache.fqdn
}

# --- STAC ---
output "stac_namespace" {
  description = "Kubernetes namespace where STAC is deployed."
  value       = kubernetes_namespace.stac.metadata[0].name
}

output "stac_data_reader_role_arn" {
  description = "IAM role ARN for the STAC data reader (Pod Identity)."
  value       = aws_iam_role.stac_data_reader.arn
}

# --- TerriaMap ---
output "terria_namespace" {
  description = "Kubernetes namespace for TerriaMap."
  value       = kubernetes_namespace.terria.metadata[0].name
}

output "terria_role_arn" {
  description = "IAM role ARN for the TerriaMap service account (Pod Identity)."
  value       = aws_iam_role.terria.arn
}

output "terria_service_account_name" {
  description = "Service account name for TerriaMap."
  value       = kubernetes_service_account.terria.metadata[0].name
}

output "terria_configmap_name" {
  description = "Name of the ConfigMap containing TerriaMap bucket configuration."
  value       = kubernetes_config_map.terria_config.metadata[0].name
}

# --- Tile server ---
output "tileserver_namespace" {
  description = "Kubernetes namespace for the tile server."
  value       = kubernetes_namespace.tileserver.metadata[0].name
}
