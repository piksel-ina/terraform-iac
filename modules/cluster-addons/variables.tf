variable "cluster_name" {
  description = "EKS cluster name; used for IAM/Pod Identity association names and external-dns TXT owner ID."
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., 'production'); used to construct external-dns external ID."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "cert_manager_chart_version" {
  description = "cert-manager Helm chart version."
  type        = string
  default     = "v1.21.1"
}

variable "ingress_nginx_chart_version" {
  description = "ingress-nginx Helm chart version."
  type        = string
  default     = "4.15.1"
}

variable "metrics_server_chart_version" {
  description = "metrics-server Helm chart version."
  type        = string
  default     = "3.13.1"
}

variable "external_dns_chart_version" {
  description = "external-dns Helm chart version."
  type        = string
  default     = "1.21.1"
}

variable "external_dns_target_role_arn" {
  description = "Route53-managing role in the shared account. Assumed via EKS Pod Identity target role chaining."
  type        = string
}

variable "external_dns_domain_filters" {
  description = "Route53 domain names external-dns is authorized to manage."
  type        = list(string)
}

variable "external_dns_zone_id_filters" {
  description = "Route53 hosted zone IDs external-dns is authorized to manage. Prevents suffix-matching from picking up sibling subdomain zones."
  type        = list(string)
  default     = []
}

variable "acme_email" {
  description = "Email address used for Let's Encrypt ACME account registration."
  type        = string
}

variable "default_tags" {
  description = "Default tags applied to AWS resources."
  type        = map(string)
  default     = {}
}
