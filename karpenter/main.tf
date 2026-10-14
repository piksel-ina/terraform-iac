terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

locals {
  cluster          = var.cluster_name
  tags             = var.default_tags
  oidc_provider    = var.oidc_provider_arn
  cluster_endpoint = var.cluster_endpoint
}

# --- Karpenter (magic autoscaler) ---
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.24.0"

  cluster_name         = local.cluster
  namespace            = "karpenter"
  enable_inline_policy = true

  # Node IAM role policies (for EC2 instances)
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore            = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEBSCSIDriverPolicy                = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    AmazonCNIPolicy                         = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    AmazonElasticFileSystemClientFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
    AmazonEC2ContainerRegistryReadOnly      = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  # Karpenter controller additional IAM policy statements
  iam_policy_statements = [
    {
      sid       = "CustomAllowRegionalReadActions"
      effect    = "Allow"
      resources = ["*"]
      actions = [
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSpotPriceHistory",
        "ec2:DescribeSubnets"
      ]
      condition = [
        {
          test     = "StringEquals"
          variable = "aws:RequestedRegion"
          values   = ["ap-southeast-3"]
        }
      ]
    },
    {
      sid       = "CustomAllowSSMReadActions"
      effect    = "Allow"
      resources = ["arn:aws:ssm:ap-southeast-3::parameter/aws/service/*"]
      actions   = ["ssm:GetParameter"]
    },
    {
      sid    = "AllowEFSOperations"
      effect = "Allow"
      #checkov:skip=CKV_AWS_288:TODO — scope resources to specific EFS ARN instead of "*"
      resources = ["*"]
      actions = [
        "elasticfilesystem:DescribeFileSystems",
        "elasticfilesystem:DescribeMountTargets",
        "elasticfilesystem:DescribeAccessPoints",
        "ec2:DescribeAvailabilityZones",
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientRootAccess",
        "elasticfilesystem:ClientWrite"
      ]
      condition = [
        {
          test     = "StringEquals"
          variable = "aws:RequestedRegion"
          values   = ["ap-southeast-3"]
        }
      ]
    }
  ]

  tags = local.tags
}

# --- Add inline policy for cross-account ECR access to AWS EKS repositories ---
resource "aws_iam_role_policy" "karpenter_node_ecr_cross_account" {
  name = "EKS-ECR-CrossAccount-Access"
  role = module.karpenter.node_iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPullFromAWSEKSECR"
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = [
          "arn:aws:ecr:*:296578399912:repository/*",
          "arn:aws:ecr:*:602401143452:repository/*",
          "arn:aws:ecr:*:686410905891:repository/*"
        ]
      },
      {
        Sid      = "AllowAssumeECRRole"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = var.cross_account_ecr_role_arn
      }
    ]
  })
}

# --- Karpenter Helm Chart with proper wait conditions ---
resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  version          = "1.8.2"
  chart            = "karpenter"
  description      = "Karpenter autoscaler for EKS cluster"

  wait            = true
  wait_for_jobs   = true
  timeout         = 300
  cleanup_on_fail = true

  values = [
    <<-EOT
    settings:
      clusterName: ${local.cluster}
      clusterEndpoint: ${local.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    controller:
      resources:
        requests:
          cpu: 500m
          memory: 1Gi
        limits:
          cpu: 1
          memory: 2Gi
    serviceAccount:
      automountServiceAccountToken: true
    nodeSelector:
      karpenter.sh/controller: "true"
    tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
    EOT
  ]
}

# --- Add timer to make sure CRD is properly installed"
resource "time_sleep" "wait_for_karpenter" {
  depends_on      = [helm_release.karpenter]
  create_duration = "60s"
}
