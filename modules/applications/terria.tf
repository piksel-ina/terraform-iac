# --- Namespace for TerriaMap ---
resource "kubernetes_namespace" "terria" {
  count = var.enable_terria ? 1 : 0

  metadata {
    name = local.terria_namespace
    labels = {
      project     = var.project
      environment = var.environment
      name        = local.terria_namespace
    }
  }
  lifecycle {
    ignore_changes = [metadata[0].labels]
  }
}

# --- S3 access policy for the TerriaMap sharing bucket (created by the s3-bucket module) ---
resource "aws_iam_policy" "terria_s3" {
  count = var.enable_terria ? 1 : 0

  name        = "svc-${local.sa_terria}-policy"
  description = "S3 access policy for the TerriaMap sharing feature"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${coalesce(var.terria_bucket_name, "unused")}",
          "arn:aws:s3:::${coalesce(var.terria_bucket_name, "unused")}/*"
        ]
      },
      {
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${coalesce(var.terria_bucket_name, "unused")}/*"]
      }
    ]
  })

  tags = local.tags
}

# --- IAM role for the TerriaMap service account via Pod Identity ---
resource "aws_iam_role" "terria" {
  count = var.enable_terria ? 1 : 0

  name = "iam-role-for-${local.sa_terria}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "terria_s3" {
  count = var.enable_terria ? 1 : 0

  role       = aws_iam_role.terria[0].name
  policy_arn = aws_iam_policy.terria_s3[0].arn
}

resource "kubernetes_service_account" "terria" {
  count = var.enable_terria ? 1 : 0

  metadata {
    name      = local.sa_terria
    namespace = kubernetes_namespace.terria[0].metadata[0].name
    labels = {
      project     = var.project
      environment = var.environment
    }
  }
}

resource "aws_eks_pod_identity_association" "terria" {
  count = var.enable_terria ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = kubernetes_namespace.terria[0].metadata[0].name
  service_account = kubernetes_service_account.terria[0].metadata[0].name
  role_arn        = aws_iam_role.terria[0].arn

  tags = local.tags
}

# --- Bucket details for TerriaMap to consume ---
resource "kubernetes_config_map" "terria_config" {
  count = var.enable_terria ? 1 : 0

  metadata {
    name      = "terria-config"
    namespace = kubernetes_namespace.terria[0].metadata[0].name
  }
  data = {
    "bucket-name"   = coalesce(var.terria_bucket_name, "unused")
    "bucket-region" = var.aws_region
  }
}
