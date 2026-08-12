# --- Namespace for TerriaMap ---
resource "kubernetes_namespace" "terria" {
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
          "arn:aws:s3:::${var.terria_bucket_name}",
          "arn:aws:s3:::${var.terria_bucket_name}/*"
        ]
      },
      {
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${var.terria_bucket_name}/*"]
      }
    ]
  })

  tags = local.tags
}

# --- IAM role for the TerriaMap service account via Pod Identity ---
resource "aws_iam_role" "terria" {
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
  role       = aws_iam_role.terria.name
  policy_arn = aws_iam_policy.terria_s3.arn
}

resource "kubernetes_service_account" "terria" {
  metadata {
    name      = local.sa_terria
    namespace = kubernetes_namespace.terria.metadata[0].name
    labels = {
      project     = var.project
      environment = var.environment
    }
  }
}

resource "aws_eks_pod_identity_association" "terria" {
  cluster_name    = var.cluster_name
  namespace       = kubernetes_namespace.terria.metadata[0].name
  service_account = kubernetes_service_account.terria.metadata[0].name
  role_arn        = aws_iam_role.terria.arn

  tags = local.tags
}

# --- Bucket details for TerriaMap to consume ---
resource "kubernetes_config_map" "terria_config" {
  metadata {
    name      = "terria-config"
    namespace = kubernetes_namespace.terria.metadata[0].name
  }
  data = {
    "bucket-name"   = var.terria_bucket_name
    "bucket-region" = var.aws_region
  }
}
