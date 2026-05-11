locals {
  odc_namespace            = "open-datacube"
  read_buckets             = concat(var.read_external_buckets, var.internal_buckets)
  service_account_name_odc = "odc-data-reader"
  subdomain                = var.subdomains[0] # The public domain must be the first in the list
}

# --- Creates Kubernetes namespace for ODC ---
resource "kubernetes_namespace" "odc" {
  metadata {
    name = local.odc_namespace
    labels = {
      project     = var.project
      environment = var.environment
      name        = local.odc_namespace
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels
    ]
  }
}

# --- Pass ODC read secret to the odc namespace ---
resource "kubernetes_secret" "odcread_namespace_secret" {
  metadata {
    name      = "odcread-secret"
    namespace = kubernetes_namespace.odc.metadata[0].name
  }
  data = {
    username = "odcread"
    password = var.odc_read_password
  }
  type = "Opaque"
}

resource "kubernetes_secret" "odc_namespace_secret" {
  metadata {
    name      = "odc-secret"
    namespace = kubernetes_namespace.odc.metadata[0].name
  }
  data = {
    username = "odc"
    password = var.odc_write_password
  }
  type = "Opaque"
}

# --- Read-only IAM Policy ---
resource "aws_iam_policy" "read_policy" {
  name        = "svc-${local.service_account_name_odc}-read-policy"
  description = "Read-only policy for S3 buckets for ${local.service_account_name_odc}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectAcl",
        ]
        Effect = "Allow"
        Resource = flatten([
          for bucket in local.read_buckets : [
            "arn:aws:s3:::${bucket}",
            "arn:aws:s3:::${bucket}/*"
          ]
        ])
      }
    ]
  })
}

# --- IAM Role for Service Account (IRSA) ----
module "iam_eks_role_bucket_odc" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 5.0"
  role_name = "svc-${local.service_account_name_odc}"

  oidc_providers = {
    main = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["${kubernetes_namespace.odc.metadata[0].name}:${local.service_account_name_odc}"]
    }
  }

  role_policy_arns = {
    ReadPolicy = aws_iam_policy.read_policy.arn
  }
}

# --- Service Account for ODC with IRSA ---
resource "kubernetes_service_account" "odc_data_reader" {
  metadata {
    name      = local.service_account_name_odc
    namespace = kubernetes_namespace.odc.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_eks_role_bucket_odc.iam_role_arn
    }
  }

  depends_on = [
    module.iam_eks_role_bucket_odc
  ]
}

# --- Set up a cloudfront cache for the `ows` endpoint ---

# --- Create Role to assume the cross-account role in the shared account ---
resource "aws_iam_role" "odc_cloudfront_role" {
  name = "odc-cloudfront-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# --- Attach the policy to the role ---
resource "aws_iam_role_policy" "odc_cloudfront_assume_crossaccount" {
  role = aws_iam_role.odc_cloudfront_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = var.odc_cloudfront_crossaccount_role_arn
      }
    ]
  })
}

# --- Create a custom certificate ---
resource "aws_acm_certificate" "ows_cache" {
  provider          = aws.virginia
  domain_name       = "ows.${local.subdomain}"
  validation_method = "DNS"

  tags = merge(
    local.tags,
    {
      Purpose = "ows-cache"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# --- Create DNS validation records for the certificate ---
resource "aws_route53_record" "ows_certificate" {
  provider = aws.cross_account
  for_each = {
    for dvo in aws_acm_certificate.ows_cache.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.public_hosted_zone_id
}

# --- Validate the certificate ---
resource "aws_acm_certificate_validation" "ows_certificate" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.ows_cache.arn
  validation_record_fqdns = [for record in aws_route53_record.ows_certificate : record.fqdn]
}

# --- WAF WebACL for CloudFront ---
resource "aws_wafv2_web_acl" "ows_cache" {
  provider = aws.virginia
  name     = "${lower(var.project)}-${lower(var.environment)}-ows-cache-waf"
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputsMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 3
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AmazonIpReputationListMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "owsCacheWAF"
    sampled_requests_enabled   = true
  }

  tags = merge(local.tags, {
    Name = "ows-cache-waf"
  })
}

resource "aws_cloudwatch_log_group" "waf_logs" {
  region = "us-east-1"
  name   = "aws-waf-logs-${lower(var.project)}-${lower(var.environment)}-ows-cache"
  #checkov:skip=CKV_AWS_158:AWS-managed encryption sufficient for WAF logs. Custom KMS pending compliance requirements.
  #checkov:skip=CKV_AWS_338:Retention configurable via var.waf_log_retention_days. Staging uses 30 days.

  retention_in_days = var.waf_log_retention_days

  tags = merge(local.tags, {
    Name = "ows-cache-waf-logs"
  })
}

resource "aws_cloudwatch_log_resource_policy" "waf_logs" {
  provider        = aws.virginia
  policy_name     = "waf-logs-policy-${lower(var.environment)}"
  policy_document = data.aws_iam_policy_document.waf_logs.json
}

data "aws_iam_policy_document" "waf_logs" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.waf_logs.arn}:*"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "ows_cache" {
  provider = aws.virginia
  depends_on = [
    aws_cloudwatch_log_resource_policy.waf_logs,
  ]

  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.ows_cache.arn
}

# --- Create a CloudFront distribution, to cache the OWS endpoint ---
# This distribution will use the custom certificate and the cross-account role to access the OWS endpoint.
resource "aws_cloudfront_distribution" "ows_cache" {
  depends_on = [aws_acm_certificate_validation.ows_certificate]
  #checkov:skip=CKV_AWS_86:Legacy logging requires S3 ACLs (incompatible with BucketOwnerEnforced). WAF logs provide access logging coverage.
  #checkov:skip=CKV2_AWS_47:No Java-based workloads in this distribution.
  #checkov:skip=CKV_AWS_305:Custom origin backend handles root path. default_root_object not applicable for API proxy.
  #checkov:skip=CKV_AWS_310:Single-origin setup. No secondary/failover origin available for this distribution.
  #checkov:skip=CKV_AWS_374:Public-facing app intentionally globally accessible. No geo restriction needed.
  #checkov:skip=CKV2_AWS_46:False positive — distribution uses custom origin (not S3). OAI/OAC is N/A.
  origin {
    domain_name = "ows-uncached.${local.subdomain}"
    origin_id   = "owsOrigin"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 60
      origin_read_timeout      = 60
    }

    # Here is the custom header definition
    custom_header {
      name  = "X-Public-Host"
      value = "ows.${local.subdomain}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""
  web_acl_id          = aws_wafv2_web_acl.ows_cache.arn

  aliases = [
    "ows.${local.subdomain}"
  ]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "owsOrigin"

    response_headers_policy_id = aws_cloudfront_response_headers_policy.ows_cors.id

    forwarded_values {
      query_string = true
      headers = [
        "Origin",
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
      ]
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 3600
    default_ttl            = 86400
    max_ttl                = 604800
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.ows_cache.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Don't cache 500, 502, 503 or 504 errors
  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 500
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 502
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 503
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 504
  }

  tags = merge(
    local.tags,
    {
      Name = "ows-cache"
    }
  )
}

# --- Set up DNS records for the cloudfront distribution ---
resource "aws_route53_record" "ows_cache" {
  provider = aws.cross_account
  zone_id  = var.public_hosted_zone_id
  name     = "ows"
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.ows_cache.domain_name
    zone_id                = aws_cloudfront_distribution.ows_cache.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_response_headers_policy" "ows_cors" {
  name    = "ows-cors-policy"
  comment = "CORS policy for OWS"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
  }

  cors_config {
    access_control_allow_credentials = false

    access_control_allow_headers {
      items = ["*"]
    }

    access_control_allow_methods {
      items = ["GET", "HEAD", "OPTIONS", "POST"]
    }

    access_control_allow_origins {
      items = ["*"]
    }

    access_control_max_age_sec = 86400

    origin_override = true
  }
}
