resource "aws_security_group" "this" {
  name_prefix = "${var.project}-tf-codebuild-"
  description = "CodeBuild VPC access for Terraform CI/CD - egress to AWS APIs and RDS"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS to AWS APIs (S3, CodeBuild, STS, EKS, Secrets Manager)"
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "PostgreSQL to RDS within VPC"
  }

  tags = merge(var.default_tags, { Name = "${var.project}-tf-codebuild" })
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.project}-tf-codebuild"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = merge(var.default_tags, { Name = "${var.project}-tf-codebuild" })
}

# Terraform CI/CD manages all infrastructure, so it needs broad IAM permissions
# beyond what PowerUserAccess grants (which excludes IAM).
resource "aws_iam_policy" "iam" {
  #checkov:skip=CKV_AWS_289:Terraform CI/CD requires broad IAM access to manage all infrastructure.
  #checkov:skip=CKV_AWS_355:Terraform CI/CD requires broad IAM access to manage all infrastructure.
  #checkov:skip=CKV_AWS_286:Terraform CI/CD requires broad IAM access to manage all infrastructure.
  #checkov:skip=CKV_AWS_287:Terraform CI/CD requires broad IAM access to manage all infrastructure.
  #checkov:skip=CKV2_AWS_40:Terraform CI/CD requires broad IAM access to manage all infrastructure.
  name        = "${var.project}-tf-codebuild-iam-policy"
  description = "IAM permissions for the Terraform CodeBuild role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["iam:*"]
        Resource = ["*"]
      }
    ]
  })

  tags = merge(var.default_tags, { Name = "${var.project}-tf-codebuild-iam-policy" })
}

resource "aws_iam_role_policy_attachment" "poweruser" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy_attachment" "iam" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.iam.arn
}

locals {
  projects = {
    plan  = "plan"
    apply = "apply"
  }
}

resource "aws_codebuild_project" "this" {
  for_each = local.projects

  name         = "${var.project}-tf-${each.key}"
  description  = "Terraform ${each.value} for ${var.environment}"
  service_role = aws_iam_role.this.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_VERSION"
      value = var.terraform_version
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "TF_ACTION"
      value = each.value
    }

    environment_variable {
      name  = "TF_DIR"
      value = var.tf_working_dir
    }

    environment_variable {
      name  = "GITHUB_REPO"
      value = var.github_repo_url
    }
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file("${path.module}/buildspec.yml")
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${var.project}-tf-${each.key}"
      status     = "ENABLED"
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.this.id]
    subnets            = var.private_subnet_ids
    vpc_id             = var.vpc_id
  }

  tags = merge(var.default_tags, { Name = "${var.project}-tf-${each.key}" })
}
