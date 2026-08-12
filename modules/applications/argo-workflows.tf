# --- Dedicated namespace for all Argo resources ---
resource "kubernetes_namespace" "argo_workflow" {
  metadata {
    name = local.argo_namespace
    labels = {
      project     = var.project
      environment = var.environment
      name        = local.argo_namespace
    }
  }
  lifecycle {
    ignore_changes = [metadata[0].labels]
  }
}

# --- Cognito OAuth client credentials (Secrets Manager, "clientid:clientsecret") ---
data "aws_secretsmanager_secret_version" "argo_client_secret" {
  secret_id = local.cognito_secret_argo
}

resource "kubernetes_secret" "argo_server_sso" {
  metadata {
    name      = "argo-client-secret"
    namespace = kubernetes_namespace.argo_workflow.metadata[0].name
  }
  data = {
    client-id     = split(":", data.aws_secretsmanager_secret_version.argo_client_secret.secret_string)[0]
    client-secret = split(":", data.aws_secretsmanager_secret_version.argo_client_secret.secret_string)[1]
  }
  type = "Opaque"
}

# --- Master DB credentials for the argo namespace ---
resource "kubernetes_secret" "argo_db_secret" {
  metadata {
    name      = "db-secret"
    namespace = kubernetes_namespace.argo_workflow.metadata[0].name
  }
  data = {
    db_name    = local.db_name
    db_address = var.db_address
    username   = local.db_username
    password   = data.aws_secretsmanager_secret_version.db_master.secret_string
  }
}

# --- Read/write policy for the Argo artifacts bucket (created by the s3-bucket module) ---
resource "aws_iam_policy" "argo_artifact_read_write" {
  name        = "svc-${local.sa_argo_exec}-policy"
  description = "Read/write policy for the Argo Workflows artifacts bucket"

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
        Resource = [
          "arn:aws:s3:::${var.argo_artifacts_bucket_name}",
          "arn:aws:s3:::${var.argo_artifacts_bucket_name}/*"
        ]
      },
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${var.argo_artifacts_bucket_name}/*"]
      }
    ]
  })
}

# --- Read/write policy for the public data bucket and read for source buckets ---
resource "aws_iam_policy" "argo_public_bucket" {
  name        = "svc-${local.sa_argo_exec}-public-bucket-policy"
  description = "Public bucket access policy for ${local.sa_argo_exec}"

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
            "arn:aws:s3:::${bucket}/*",
            var.public_bucket_arn,
            "${var.public_bucket_arn}/*"
          ]
        ])
      },
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
        ]
        Effect   = "Allow"
        Resource = ["${var.public_bucket_arn}/*"]
      }
    ]
  })

  tags = local.tags
}

# --- IAM role for the Argo service accounts via Pod Identity ---
resource "aws_iam_role" "argo_workflow" {
  name = "iam-role-for-argo-workflow-service-account"
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

resource "aws_iam_role_policy_attachment" "argo_workflow_s3" {
  role       = aws_iam_role.argo_workflow.name
  policy_arn = aws_iam_policy.argo_artifact_read_write.arn
}

resource "aws_iam_role_policy_attachment" "argo_workflow_public_bucket" {
  role       = aws_iam_role.argo_workflow.name
  policy_arn = aws_iam_policy.argo_public_bucket.arn
}

# --- Bind both Argo service accounts (executor and server) to the role ---
resource "aws_eks_pod_identity_association" "argo_workflow" {
  for_each = toset([local.sa_argo_exec, local.sa_argo_serve])

  cluster_name    = var.cluster_name
  namespace       = kubernetes_namespace.argo_workflow.metadata[0].name
  service_account = each.value
  role_arn        = aws_iam_role.argo_workflow.arn

  tags = local.tags
}
