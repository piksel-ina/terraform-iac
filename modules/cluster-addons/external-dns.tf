resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
    labels = {
      name      = "external-dns"
      component = "external-dns"
    }
  }
}

resource "aws_iam_role" "external_dns" {
  name = "${var.cluster_name}-external-dns"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = var.default_tags
}

resource "aws_iam_role_policy" "external_dns" {
  name = "assume-crossaccount-route53"
  role = aws_iam_role.external_dns.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sts:AssumeRole", "sts:TagSession"]
      Resource = var.external_dns_target_role_arn
    }]
  })
}

resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = var.cluster_name
  namespace       = kubernetes_namespace.external_dns.metadata[0].name
  service_account = "external-dns-sa"
  role_arn        = aws_iam_role.external_dns.arn
  target_role_arn = var.external_dns_target_role_arn
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = kubernetes_namespace.external_dns.metadata[0].name
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = var.external_dns_chart_version

  wait            = true
  wait_for_jobs   = true
  timeout         = 300
  cleanup_on_fail = true

  values = [
    yamlencode({
      logLevel  = "info"
      logFormat = "json"

      provider = {
        name = "aws"
      }

      registry                = "txt"
      txtOwnerId              = "eks-cluster-${var.cluster_name}"
      txtPrefix               = "external-dns"
      policy                  = "sync"
      domainFilters           = var.external_dns_domain_filters
      publishInternalServices = true
      triggerLoopOnEvent      = true
      interval                = "30s"

      serviceAccount = {
        create = true
        name   = "external-dns-sa"
        labels = {
          app       = "external-dns"
          component = "external-dns"
        }
      }

      podLabels = {
        app       = "external-dns"
        component = "external-dns"
      }

      extraArgs = concat(
        [for zid in var.external_dns_zone_id_filters : "--zone-id-filter=${zid}"],
      )

      env = [
        {
          name  = "AWS_DEFAULT_REGION"
          value = var.aws_region
        },
      ]

      nodeSelector = local.controller_node_selector
      tolerations  = [local.critical_addons_toleration]

      resources = {
        requests = { cpu = "100m", memory = "128Mi" }
        limits   = { cpu = "200m", memory = "256Mi" }
      }
    }),
  ]

  depends_on = [aws_eks_pod_identity_association.external_dns]
}
