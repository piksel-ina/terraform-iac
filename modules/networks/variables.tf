variable "project" {
  description = "Project name; used in resource naming."
  type        = string
}

variable "environment" {
  description = "Environment name; used in resource naming."
  type        = string
}

variable "aws_region" {
  description = "AWS region; used to derive AZ short names in subnet naming."
  type        = string
}

variable "vpc_cidr" {
  description = "Primary VPC CIDR block. Must be /16 to satisfy the subnet layout."
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && tonumber(split("/", var.vpc_cidr)[1]) == 16
    error_message = "vpc_cidr must be a valid /16 CIDR block."
  }
}

variable "secondary_cidr_blocks" {
  description = "Additional CIDR blocks attached to the VPC. Use to extend IP space when the primary /16 fills up."
  type        = list(string)
  default     = []
}

variable "az_count" {
  description = "Number of Availability Zones to use (1-3)."
  type        = number
  validation {
    condition     = var.az_count >= 1 && var.az_count <= 3
    error_message = "az_count must be between 1 and 3."
  }
}

variable "cluster_name" {
  description = "EKS cluster name consuming this VPC; used for subnet discovery tags."
  type        = string
}

variable "nat_strategy" {
  description = "NAT gateway placement: 'single' (one shared NAT, cheaper) or 'per_az' (one NAT per AZ, higher cost + AZ-failure isolation)."
  type        = string
  default     = "single"
  validation {
    condition     = contains(["single", "per_az"], var.nat_strategy)
    error_message = "nat_strategy must be 'single' or 'per_az'."
  }
}

variable "flow_logs_enabled" {
  description = "Enable VPC Flow Logs to CloudWatch."
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "CloudWatch Logs retention for VPC Flow Logs, in days."
  type        = number
  default     = 90
  validation {
    condition     = var.flow_logs_retention_days >= 1 && var.flow_logs_retention_days <= 3650
    error_message = "flow_logs_retention_days must be between 1 and 3650."
  }
}

variable "default_tags" {
  description = "Default tags applied to all resources."
  type        = map(string)
  default     = {}
}
