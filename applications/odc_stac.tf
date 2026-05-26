locals {
  stac_namespace            = "odc-stac"
  service_account_name_stac = "stac-data-reader"
}

# --- Creates Kubernetes namespace for ODC SpatioTemporal Asset Catalog  ---
resource "kubernetes_namespace" "stac" {
  metadata {
    name = local.stac_namespace
    labels = {
      project     = var.project
      environment = var.environment
      name        = local.stac_namespace
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels
    ]
  }
}

# --- Pass Stac read secret to the odc-stac namespace. Writing is done in Argo ---
resource "kubernetes_secret" "stacread_namespace_secret" {
  metadata {
    name      = "stacread-secret"
    namespace = kubernetes_namespace.stac.metadata[0].name
  }
  data = {
    username = "stacread"
    password = var.stac_read_password
  }
  type = "Opaque"
}

resource "kubernetes_secret" "stac_namespace_secret" {
  metadata {
    name      = "stac-secret"
    namespace = kubernetes_namespace.stac.metadata[0].name
  }
  data = {
    username = "stac"
    password = var.stac_write_password
  }
  type = "Opaque"
}

resource "aws_iam_policy" "stac_read_policy" {
  name        = "svc-${local.service_account_name_stac}-read-policy"
  description = "Read-only policy for S3 buckets for ${local.service_account_name_stac}"

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

module "iam_eks_role_stac" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 5.0"
  role_name = "svc-${local.service_account_name_stac}"

  oidc_providers = {
    main = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["${kubernetes_namespace.stac.metadata[0].name}:${local.service_account_name_stac}"]
    }
  }

  role_policy_arns = {
    ReadPolicy = aws_iam_policy.stac_read_policy.arn
  }
}

resource "kubernetes_service_account" "stac_data_reader" {
  metadata {
    name      = local.service_account_name_stac
    namespace = kubernetes_namespace.stac.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_eks_role_stac.iam_role_arn
    }
  }

  depends_on = [
    module.iam_eks_role_stac
  ]
}
