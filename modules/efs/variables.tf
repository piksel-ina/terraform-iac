variable "cluster_name" {
  description = "EKS cluster name; used for resource naming and Pod Identity association."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID hosting the EFS mount targets."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for EFS mount targets (typically the cluster's private subnets, one per AZ)."
  type        = list(string)
}

variable "node_security_group_id" {
  description = "Security group ID of the EKS cluster nodes; used for NFS ingress rule."
  type        = string
}

variable "csi_service_account" {
  description = "Kubernetes service account for the EFS CSI controller."
  type = object({
    namespace = string
    name      = string
  })
  default = {
    namespace = "kube-system"
    name      = "efs-csi-controller-sa"
  }
}

variable "backup_enabled" {
  description = "Enable AWS Backup policy on the EFS file system."
  type        = bool
  default     = false
}

variable "transition_to_ia_days" {
  description = "Days of no access before transitioning objects to Infrequent Access storage class."
  type        = string
  default     = "AFTER_30_DAYS"
}

variable "default_tags" {
  description = "Default tags applied to all resources."
  type        = map(string)
  default     = {}
}
