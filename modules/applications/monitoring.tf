# --- Monitoring namespace (always created, even when Grafana is disabled) ---
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = local.monitoring_namespace
    labels = {
      project     = var.project
      environment = var.environment
      name        = local.monitoring_namespace
    }
  }
  lifecycle {
    ignore_changes = [metadata[0].labels]
  }
}

# --- Cognito OAuth client credentials (Secrets Manager, "clientid:clientsecret") ---
data "aws_secretsmanager_secret_version" "grafana_client_secret" {
  count     = var.enable_grafana ? 1 : 0
  secret_id = local.cognito_secret_grafana
}

# --- Grafana admin password (fallback access when OAuth is unavailable) ---
resource "random_bytes" "grafana_admin_password" {
  count  = var.enable_grafana ? 1 : 0
  length = 32
}

resource "kubernetes_secret" "grafana_admin_credentials" {
  count = var.enable_grafana ? 1 : 0

  metadata {
    name      = "grafana-admin-secret"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  data = {
    admin-user     = "grafanasuperuser"
    admin-password = random_bytes.grafana_admin_password[0].hex
  }
  type = "Opaque"
}

# --- IAM role for Grafana CloudWatch access via Pod Identity ---
resource "aws_iam_role" "grafana" {
  count = var.enable_grafana ? 1 : 0

  name = "${var.cluster_name}-grafana-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = merge(local.tags, { Name = "${var.cluster_name}-grafana-role" })
}

data "aws_iam_policy_document" "grafana_cloudwatch" {
  count = var.enable_grafana ? 1 : 0
  #checkov:skip=CKV_AWS_356:CloudWatch/Logs/EC2 read actions require Resource="*". TODO: scope when defined.
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetInsightRuleReport"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogRecord"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "grafana_cloudwatch" {
  count = var.enable_grafana ? 1 : 0
  #checkov:skip=CKV_AWS_355:CloudWatch/Logs/EC2 read actions require Resource="*". TODO: scope when defined.
  name        = "${var.cluster_name}-grafana-cloudwatch-policy"
  description = "CloudWatch read access for Grafana"
  policy      = data.aws_iam_policy_document.grafana_cloudwatch[0].json
}

resource "aws_iam_role_policy_attachment" "grafana_cloudwatch" {
  count = var.enable_grafana ? 1 : 0

  role       = aws_iam_role.grafana[0].name
  policy_arn = aws_iam_policy.grafana_cloudwatch[0].arn
}

resource "aws_eks_pod_identity_association" "grafana" {
  count = var.enable_grafana ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = kubernetes_namespace.monitoring.metadata[0].name
  service_account = local.sa_grafana
  role_arn        = aws_iam_role.grafana[0].arn

  tags = local.tags
}

# --- Cognito OAuth secret consumed by Grafana ---
resource "kubernetes_secret" "grafana_oauth" {
  count = var.enable_grafana ? 1 : 0

  metadata {
    name      = "grafana-oauth-secret"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  data = {
    client_id     = split(":", data.aws_secretsmanager_secret_version.grafana_client_secret[0].secret_string)[0]
    client_secret = split(":", data.aws_secretsmanager_secret_version.grafana_client_secret[0].secret_string)[1]
  }
  type = "Opaque"
}

# --- Grafana Helm values for GitOps to consume ---
resource "kubernetes_secret" "grafana_values" {
  count = var.enable_grafana ? 1 : 0

  metadata {
    name      = "grafana-values"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  data = {
    "values.yaml" = templatefile("${path.module}/config/grafana.yaml", {
      cognito_auth_domain = var.cognito_auth_domain
      grafana_subdomain   = local.grafana_subdomain
    })
  }
  type = "Opaque"
}
