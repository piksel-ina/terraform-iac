terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "project" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. staging, production)"
  type        = string
}

variable "domain_name" {
  description = "Full domain name for the website (e.g. staging.piksel.big.go.id)"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for DNS records"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "cloudfront_price_class" {
  description = "CloudFront price class (e.g. PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"
}

variable "csp_hashes" {
  description = "Hashes of the inline scripts and styles the site is allowed to run. Regenerate from a build when the site's inline code changes."
  type = object({
    script = list(string)
    style  = list(string)
  })
  default = {
    script = []
    style  = []
  }
}
