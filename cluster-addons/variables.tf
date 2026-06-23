variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "efs_filesystem_id" {
  description = "EFS filesystem ID for StorageClass and PV references"
  type        = string
}

variable "efs_coastline_readonly_access_point_id" {
  description = "EFS access point ID for read-only coastline mount used by argo-workflows"
  type        = string
}

variable "efs_csi_irsa_role_arn" {
  description = "IAM role ARN for EFS CSI driver controller service account"
  type        = string
}

variable "aws_region" {
  description = "AWS region for addon configuration"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
}

variable "cert_manager_chart_version" {
  description = "cert-manager Helm chart version"
  type        = string
  default     = "1.17.2"
}

variable "ingress_nginx_chart_version" {
  description = "ingress-nginx Helm chart version"
  type        = string
  default     = "4.12.1"
}

variable "metrics_server_chart_version" {
  description = "metrics-server Helm chart version"
  type        = string
  default     = "3.12.2"
}

variable "nvidia_device_plugin_chart_version" {
  description = "nvidia-device-plugin Helm chart version"
  type        = string
  default     = "0.14.3"
}

variable "efs_csi_chart_version" {
  description = "aws-efs-csi-driver Helm chart version"
  type        = string
  default     = "3.1.7"
}
