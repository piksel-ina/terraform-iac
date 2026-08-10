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

variable "pg_host" {
  description = "Override PostgreSQL host for the terraform-managed database resources. Set to 'localhost' when tunnelling via SSM/port-forward on first apply."
  type        = string
  default     = ""
}

variable "pg_port" {
  description = "PostgreSQL port for the terraform-managed database resources. Use the local port when tunnelling."
  type        = number
  default     = 5432
}
