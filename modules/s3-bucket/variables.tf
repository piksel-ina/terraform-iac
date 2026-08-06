variable "project" {
  description = "Project name; used in bucket naming."
  type        = string
}

variable "environment" {
  description = "Environment name; used in bucket naming."
  type        = string
}

variable "default_tags" {
  description = "Default tags applied to all buckets."
  type        = map(string)
  default     = {}
}

variable "create_iac_state" {
  description = "Create the IaC (Terraform/OpenTofu) state bucket."
  type        = bool
  default     = false
}

variable "create_public_data" {
  description = "Create the public data bucket."
  type        = bool
  default     = false
}

variable "create_argo_artifacts" {
  description = "Create the Argo Workflows artifacts bucket."
  type        = bool
  default     = false
}

variable "create_terria" {
  description = "Create the Terria bucket."
  type        = bool
  default     = false
}

variable "iac_state_retention_days" {
  description = "Days to retain non-current versions of the IaC state bucket."
  type        = number
  default     = 90
}

variable "artifact_expiration_days" {
  description = "Days before Argo/Terria artifact objects expire."
  type        = number
  default     = 60
}
