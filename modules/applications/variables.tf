variable "project" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The name of the environment."
  type        = string
}

variable "aws_region" {
  description = "Region the workload resources are deployed in."
  type        = string
  default     = "ap-southeast-3"
}

variable "default_tags" {
  description = "Default tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "EKS cluster name. Pod Identity associations are created against this cluster."
  type        = string
}

variable "account_id" {
  description = "AWS account ID hosting the workload cluster."
  type        = string
}

variable "subdomains" {
  description = "Public subdomains for the environment. The public domain must be first in the list."
  type        = list(string)
}

variable "public_hosted_zone_id" {
  description = "ID of the public Route53 hosted zone (in the shared account, reached via the cross_account provider)."
  type        = string
}

variable "cognito_auth_domain" {
  description = "Cognito Hosted UI domain used by all OAuth clients (e.g. oauth.piksel.big.go.id)."
  type        = string
}

variable "odc_cloudfront_crossaccount_role_arn" {
  description = "ARN of the cross-account IAM role in the shared account used for OWS CloudFront/Route53."
  type        = string
}

variable "internal_buckets" {
  description = "Internal S3 bucket names granted read access to data-reader roles."
  type        = list(string)
  default     = []
}

variable "read_external_buckets" {
  description = "External S3 bucket names (e.g. usgs-landsat) granted read access to data-reader roles."
  type        = list(string)
  default     = []
}

variable "public_bucket_arn" {
  description = "ARN of the public data S3 bucket used for Argo workflow outputs and user reads."
  type        = string
}

variable "argo_artifacts_bucket_name" {
  description = "Name of the Argo Workflows artifacts bucket (created by the s3-bucket module)."
  type        = string
}

variable "terria_bucket_name" {
  description = "Name of the TerriaMap sharing bucket (created by the s3-bucket module)."
  type        = string
}

variable "db_namespace" {
  description = "Kubernetes namespace holding the shared database secrets (created by the rds module)."
  type        = string
}

variable "db_address" {
  description = "RDS hostname."
  type        = string
}

variable "k8s_db_service" {
  description = "Cluster-local DNS name that resolves to the RDS endpoint."
  type        = string
}

variable "db_user_passwords" {
  description = "Map of application DB user passwords keyed by role name (from the rds module user_passwords output)."
  type        = map(string)
  sensitive   = true
}

variable "waf_log_retention_days" {
  description = "Number of days to retain OWS cache WAF logs in CloudWatch."
  type        = number
  default     = 365
}

variable "enable_grafana" {
  description = "Whether to create Grafana resources (secrets, IAM, Helm values). The monitoring namespace is always created."
  type        = bool
  default     = true
}
