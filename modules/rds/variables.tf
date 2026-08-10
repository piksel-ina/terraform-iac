variable "project" {
  description = "Project name; used as the base DB name and username prefix."
  type        = string
}

variable "environment" {
  description = "Environment name; used in the master username."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name; used in the RDS instance identifier."
  type        = string
}

variable "default_tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC that hosts the DB and its security group."
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR permitted to reach the DB on 5432."
  type        = string
}

variable "private_subnets_ids" {
  description = "Private subnets for the DB subnet group."
  type        = list(string)
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "17.10"
}

variable "family" {
  description = "DB parameter group family."
  type        = string
  default     = "postgres17"
}

variable "major_engine_version" {
  description = "Major engine version passed to the RDS module."
  type        = string
  default     = "17"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.m7g.large"

  validation {
    condition     = can(regex("^db\\.", var.instance_class))
    error_message = "Instance class must start with 'db.'"
  }
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB."
  type        = number
  default     = 70
}

variable "max_allocated_storage" {
  description = "Upper bound for storage autoscaling in GiB. Set to 0 to disable autoscaling."
  type        = number
  default     = 200
}

variable "backup_retention_period" {
  description = "Number of days automated backups are retained."
  type        = number
  default     = 30

  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention must be between 0 and 35 days."
  }
}

variable "multi_az" {
  description = "Deploy the DB across multiple AZs."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply modifications immediately instead of during the next maintenance window."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Prevent accidental deletion of the DB instance."
  type        = bool
  default     = true
}

variable "pg_host" {
  description = "Override PostgreSQL host for the provider. Use 'localhost' when tunnelling via SSM/port-forward."
  type        = string
  default     = ""
}

variable "pg_port" {
  description = "PostgreSQL port. Use the local port when tunnelling."
  type        = number
  default     = 5432
}
