variable "project" {
  description = "Project name; used to name CodeBuild projects and IAM resources."
  type        = string
}

variable "environment" {
  description = "Environment name; used in resource descriptions."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "ap-southeast-3"
}

variable "account_id" {
  description = "AWS account ID; used to build the CloudWatch log group ARNs."
  type        = string
}

variable "vpc_id" {
  description = "VPC that hosts the CodeBuild projects."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for the CodeBuild VPC configuration."
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block permitted for the CodeBuild egress to RDS on 5432."
  type        = string
}

variable "tf_state_bucket_arn" {
  description = "ARN of the Terraform state S3 bucket the CodeBuild role must access."
  type        = string
}

variable "github_repo_url" {
  description = "HTTPS URL of the terraform-iac Git repository cloned inside the build."
  type        = string
  default     = "https://github.com/piksel-ina/terraform-iac.git"
}

variable "tf_working_dir" {
  description = "Terraform root directory to run init/plan/apply against (relative to repo root)."
  type        = string
  default     = "production"
}

variable "terraform_version" {
  description = "Terraform version installed in the CodeBuild image."
  type        = string
  default     = "1.14.8"
}

variable "default_tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
