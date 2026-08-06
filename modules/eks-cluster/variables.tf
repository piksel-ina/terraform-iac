variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "eks_version" {
  description = "Kubernetes version for the control plane."
  type        = string
}

variable "coredns_version" {
  description = "CoreDNS addon version."
  type        = string
}

variable "kube_proxy_version" {
  description = "kube-proxy addon version."
  type        = string
}

variable "vpc_cni_version" {
  description = "VPC CNI addon version."
  type        = string
}

variable "ebs_csi_version" {
  description = "EBS CSI driver addon version."
  type        = string
}

variable "pod_identity_version" {
  description = "EKS Pod Identity Agent addon version."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the cluster."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for control plane ENIs, node groups, and EFS mount targets."
  type        = list(string)
}

variable "sso_admin_role_arn" {
  description = "ARN of the SSO admin role granted cluster-admin access."
  type        = string
}

variable "additional_access_entries" {
  description = "Additional cluster access entries (e.g., CodeBuild). Keyed by descriptive name."
  type = map(object({
    principal_arn     = string
    kubernetes_groups = optional(list(string), [])
    policy_arn        = optional(string, "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy")
    access_scope_type = optional(string, "cluster")
  }))
  default = {}
}

variable "cross_account_ecr_role_arn" {
  description = "Shared-account ECR role that node instances can assume for cross-account image pulls."
  type        = string
  default     = "arn:aws:iam::686410905891:role/piksel-eks-ecr-access"
}

variable "endpoint_public_access" {
  description = "Whether the EKS API endpoint is publicly accessible."
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint. Use ['0.0.0.0/0'] for unrestricted."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "system_node_instance_types" {
  description = "Instance types for the system node groups (on-demand + spot fleet)."
  type = object({
    on_demand = string
    spot      = list(string)
  })
  default = {
    on_demand = "m6i.large"
    spot      = ["m6i.large", "m6a.large", "m5.large", "m5a.large", "m5n.large"]
  }
}

variable "efs_backup_enabled" {
  description = "Enable AWS Backup policy on the EFS file system."
  type        = bool
  default     = false
}

variable "default_tags" {
  description = "Default tags applied to all resources."
  type        = map(string)
  default     = {}
}
