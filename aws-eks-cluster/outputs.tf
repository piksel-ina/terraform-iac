# --- Eks Cluster Outputs ---
output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "EKS Cluster Certificate Authority Data"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_provider_arn" {
  description = "EKS Cluster OIDC Provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  description = "EKS Cluster OIDC Issuer URL"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_tls_certificate_sha1_fingerprint" {
  description = "EKS Cluster TLS Certificate SHA1 Fingerprint"
  value       = module.eks.cluster_tls_certificate_sha1_fingerprint
}

output "authentication_token" {
  description = "Token to use to authenticate with the cluster"
  value       = data.aws_eks_cluster_auth.this.token
  sensitive   = true
}

output "efs_filesystem_id" {
  description = "EFS filesystem ID for CSI driver and StorageClasses"
  value       = aws_efs_file_system.data.id
}

output "efs_csi_irsa_role_arn" {
  description = "IAM role ARN for EFS CSI driver controller service account"
  value       = module.efs_csi_irsa_role.iam_role_arn
}

output "efs_security_group_id" {
  description = "Security group ID of the EFS mount targets (for granting NFS access to in-VPC clients)"
  value       = aws_security_group.efs.id
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster control plane ENIs"
  value       = module.eks.cluster_security_group_id
}
