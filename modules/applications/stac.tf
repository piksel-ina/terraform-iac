# --- Namespace for the ODC SpatioTemporal Asset Catalog ---
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
    ignore_changes = [metadata[0].labels]
  }
}

# --- STAC DB credentials in the stac namespace (writes happen in Argo) ---
resource "kubernetes_secret" "stacread_namespace_secret" {
  metadata {
    name      = "stacread-secret"
    namespace = kubernetes_namespace.stac.metadata[0].name
  }
  data = {
    username = "stacread"
    password = var.db_user_passwords["stacread"]
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
    password = var.db_user_passwords["stac"]
  }
  type = "Opaque"
}

# --- Read-only S3 policy for the STAC data reader ---
resource "aws_iam_policy" "stac_read" {
  name        = "svc-${local.sa_stac_read}-read-policy"
  description = "Read-only S3 policy for ${local.sa_stac_read}"

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

# --- IAM role for the STAC data reader via Pod Identity ---
resource "aws_iam_role" "stac_data_reader" {
  name = "svc-${local.sa_stac_read}"
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

resource "aws_iam_role_policy_attachment" "stac_data_reader" {
  role       = aws_iam_role.stac_data_reader.name
  policy_arn = aws_iam_policy.stac_read.arn
}

resource "kubernetes_service_account" "stac_data_reader" {
  metadata {
    name      = local.sa_stac_read
    namespace = kubernetes_namespace.stac.metadata[0].name
  }
}

resource "aws_eks_pod_identity_association" "stac_data_reader" {
  cluster_name    = var.cluster_name
  namespace       = kubernetes_namespace.stac.metadata[0].name
  service_account = kubernetes_service_account.stac_data_reader.metadata[0].name
  role_arn        = aws_iam_role.stac_data_reader.arn

  tags = local.tags
}
