variable "project" {
  description = "The name of the project"
  type        = string
  default     = "Piksel"
}

variable "environment" {
  description = "The environment of the deployment"
  type        = string
  default     = "Production"
}

variable "aws_region" {
  description = "Region to deploy resources in"
  type        = string
  default     = "ap-southeast-3"
}

variable "default_tags" {
  description = "A map of default tags to apply to all AWS resources"
  type        = map(string)
  default = {
    "ManagedBy"   = "Terraform"
    "Project"     = "Piksel"
    "Owner"       = "Piksel-Devops-Team"
    "Environment" = "Production"
  }
}
