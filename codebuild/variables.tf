variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-3"
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for CodeBuild VPC config"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for CodeBuild VPC config"
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block for scoping security group egress rules"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name for IAM policy scoping"
  type        = string
}

variable "terraform_version" {
  description = "Terraform version to install in CodeBuild"
  type        = string
  default     = "1.14.8"
}

variable "tf_state_bucket_arn" {
  description = "ARN of the Terraform state S3 bucket"
  type        = string
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default     = {}
}
