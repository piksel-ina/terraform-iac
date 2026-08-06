output "cluster_endpoint" {
  description = "EKS cluster API endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data."
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_provider_arn" {
  description = "EKS cluster OIDC provider ARN. Kept for future consumers; core addons use Pod Identity instead."
  value       = module.eks.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL."
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_tls_certificate_sha1_fingerprint" {
  description = "EKS cluster TLS certificate SHA1 fingerprint."
  value       = module.eks.cluster_tls_certificate_sha1_fingerprint
}

output "cluster_security_group_id" {
  description = "Security group ID on the EKS control plane ENIs."
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to managed node groups. Downstream modules (EFS, add-ons) reference this to allow ingress from cluster nodes."
  value       = module.eks.node_security_group_id
}

output "authentication_token" {
  description = "Token to authenticate with the cluster."
  value       = data.aws_eks_cluster_auth.this.token
  sensitive   = true
}
