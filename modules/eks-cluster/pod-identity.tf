locals {
  pod_identity_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_role" "vpc_cni" {
  name               = "${var.cluster_name}-vpc-cni"
  assume_role_policy = local.pod_identity_assume_role_policy
  tags               = var.default_tags
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  role       = aws_iam_role.vpc_cni.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role" "ebs_csi" {
  name               = "${var.cluster_name}-ebs-csi"
  assume_role_policy = local.pod_identity_assume_role_policy
  tags               = var.default_tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_policy" "assume_ecr_role" {
  name        = "${var.cluster_name}-assume-ecr-role"
  description = "Allow EKS nodes to assume the cross-account ECR role and pull directly from shared ECR repositories."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AssumeECRRole"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = var.cross_account_ecr_role_arn
      },
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
    ]
  })
}
