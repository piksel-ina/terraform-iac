module "controller" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.24"

  cluster_name = var.cluster_name

  namespace                       = "karpenter"
  service_account                 = "karpenter"
  create_pod_identity_association = true
  enable_inline_policy            = true

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  tags = var.default_tags
}

resource "aws_iam_role_policy" "controller_ssm_read" {
  name = "KarpenterSSMReadForAMIAliases"
  role = module.controller.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "AllowSSMReadForAMIAliases"
      Effect   = "Allow"
      Action   = ["ssm:GetParameter"]
      Resource = ["arn:aws:ssm:ap-southeast-3::parameter/aws/service/*"]
    }]
  })
}

resource "aws_iam_role_policy" "node_ecr_cross_account" {
  name = "EKS-ECR-CrossAccount-Access"
  role = module.controller.node_iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPullFromSharedECR"
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
        ]
        Resource = [
          "arn:aws:ecr:*:296578399912:repository/*",
          "arn:aws:ecr:*:602401143452:repository/*",
          "arn:aws:ecr:*:686410905891:repository/*",
        ]
      },
      {
        Sid      = "AllowAssumeECRRole"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = var.cross_account_ecr_role_arn
      },
    ]
  })
}

resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "karpenter"
  create_namespace = true
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = var.karpenter_chart_version

  wait            = true
  wait_for_jobs   = true
  timeout         = 300
  cleanup_on_fail = true

  values = [
    yamlencode({
      settings = {
        clusterName       = var.cluster_name
        clusterEndpoint   = var.cluster_endpoint
        interruptionQueue = module.controller.queue_name
      }
      controller = {
        resources = {
          requests = { cpu = "500m", memory = "1Gi" }
          limits   = { cpu = "1", memory = "2Gi" }
        }
      }
      nodeSelector = {
        "karpenter.sh/controller" = "true"
      }
      tolerations = [
        {
          key      = "CriticalAddonsOnly"
          operator = "Equal"
          value    = "true"
          effect   = "NoSchedule"
        },
      ]
    }),
  ]

  depends_on = [module.controller]
}

resource "time_sleep" "wait_for_karpenter_crds" {
  depends_on      = [helm_release.karpenter]
  create_duration = "60s"
}
