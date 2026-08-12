# --- Dedicated namespace for JupyterHub ---
resource "kubernetes_namespace" "hub" {
  metadata {
    name = local.jhub_namespace
    labels = {
      project     = var.project
      environment = var.environment
      name        = local.jhub_namespace
    }
  }
  lifecycle {
    ignore_changes = [metadata[0].labels]
  }
}

# --- DB credentials for the hub namespace ---
resource "kubernetes_secret" "hub_db_secret" {
  metadata {
    name      = "hub-db-secret"
    namespace = kubernetes_namespace.hub.metadata[0].name
  }
  data = {
    username         = "jupyterhub"
    password         = var.db_user_passwords["jupyterhub"]
    odcread-password = var.db_user_passwords["odcread"]
    odc-password     = var.db_user_passwords["odc"]
  }
  type = "Opaque"
}

# --- Cognito OAuth client credentials (Secrets Manager, "clientid:clientsecret") ---
data "aws_secretsmanager_secret_version" "hub_client_secret" {
  secret_id = local.cognito_secret_jupyterhub
}

# --- JupyterHub internal secrets ---
resource "random_id" "jhub_hub_cookie_secret_token" {
  byte_length = 32
}

resource "random_id" "jhub_proxy_secret_token" {
  byte_length = 32
}

resource "random_password" "dask_gateway_api_token" {
  length  = 64
  special = false
  upper   = false
}

# --- JupyterHub Helm values for GitOps to consume ---
resource "kubernetes_secret" "jupyterhub" {
  metadata {
    name      = "jupyterhub"
    namespace = kubernetes_namespace.hub.metadata[0].name
  }
  data = {
    "values.yaml" = templatefile("${path.module}/config/jupyterhub.yaml", {
      region    = var.aws_region
      host_name = local.jhub_subdomain

      jhub_auth_client_id     = split(":", data.aws_secretsmanager_secret_version.hub_client_secret.secret_string)[0]
      jhub_auth_client_secret = split(":", data.aws_secretsmanager_secret_version.hub_client_secret.secret_string)[1]

      cognito_auth_domain = var.cognito_auth_domain

      jhub_db_name     = "jupyterhub"
      jhub_db_username = "jupyterhub"
      jhub_db_password = var.db_user_passwords["jupyterhub"]
      jhub_db_hostname = var.k8s_db_service

      jhub_hub_cookie_secret_token = random_id.jhub_hub_cookie_secret_token.hex
      jhub_proxy_secret_token      = random_id.jhub_proxy_secret_token.hex
      jhub_dask_gateway_api_token  = random_password.dask_gateway_api_token.result

      odcread_password = var.db_user_passwords["odcread"]
    })
  }
  type = "Opaque"
}

# --- S3 read policy so JupyterHub users can read Landsat/public data ---
resource "aws_iam_policy" "hub_user_read" {
  #checkov:skip=CKV_AWS_288:Read-only S3 policy scoped to known external/public buckets.
  name        = "jupyterhub-user-read-policy"
  description = "S3 read access for JupyterHub users (USGS Landsat and public data)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
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
        Effect   = "Allow"
        Action   = ["s3:GetBucketRequestPayment"]
        Resource = flatten([for bucket in local.read_buckets : ["arn:aws:s3:::${bucket}", var.public_bucket_arn]])
      }
    ]
  })
}

# --- IAM role for the JupyterHub user-read service account via Pod Identity ---
resource "aws_iam_role" "hub_user_read" {
  name = "svc-hub-user-read"
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

resource "aws_iam_role_policy_attachment" "hub_user_read" {
  role       = aws_iam_role.hub_user_read.name
  policy_arn = aws_iam_policy.hub_user_read.arn
}

resource "kubernetes_service_account" "hub_user_read" {
  metadata {
    name      = local.sa_hub_read
    namespace = kubernetes_namespace.hub.metadata[0].name
  }
  automount_service_account_token = true
}

resource "aws_eks_pod_identity_association" "hub_user_read" {
  cluster_name    = var.cluster_name
  namespace       = kubernetes_namespace.hub.metadata[0].name
  service_account = kubernetes_service_account.hub_user_read.metadata[0].name
  role_arn        = aws_iam_role.hub_user_read.arn

  tags = local.tags
}
