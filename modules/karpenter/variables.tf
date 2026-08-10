variable "cluster_name" {
  description = "EKS cluster name; used for controller settings, subnet/SG discovery, and IAM role names."
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS API endpoint. Passed to the Karpenter controller."
  type        = string
}

variable "karpenter_chart_version" {
  description = "Karpenter Helm chart version."
  type        = string
  default     = "1.14.0"
}

variable "default_ami_alias" {
  description = "AMI alias used by non-GPU EC2NodeClasses (e.g. 'al2023@v20260801')."
  type        = string
  default     = "al2023@v20260801"
}

variable "gpu_ami_name" {
  description = "EKS-optimized NVIDIA AL2023 AMI name for GPU EC2NodeClasses."
  type        = string
  default     = "amazon-eks-node-al2023-x86_64-nvidia-1.36-v20260801"
}

variable "default_nodepool_cpu_limit" {
  description = "CPU limit (cores) for the default and Jupyter NodePools."
  type        = number
  default     = 10000
}

variable "data_production_cpu_limit" {
  description = "CPU limit (cores) for the data-production NodePools."
  type        = number
  default     = 10000
}

variable "gpu_nodepool_limit" {
  description = "GPU limit for the GPU NodePool."
  type        = number
  default     = 20
}

variable "cross_account_ecr_role_arn" {
  description = "Shared-account ECR role that Karpenter-provisioned nodes can assume for cross-account image pulls."
  type        = string
  default     = "arn:aws:iam::686410905891:role/piksel-eks-ecr-access"
}

variable "default_tags" {
  description = "Default tags applied to all resources."
  type        = map(string)
  default     = {}
}
