locals {
  admin_name           = "piksel-admin"
  admin_region         = var.aws_region
  efs_dns              = "${module.eks-cluster.efs_filesystem_id}.efs.${var.aws_region}.amazonaws.com"
  admin_instance_type  = "m6i.xlarge"
  admin_root_volume_gb = 150
}

# ============================================================
# IAM
# ============================================================

data "aws_iam_policy_document" "admin_ec2_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "admin_instance" {
  provider           = aws.aws
  name               = "${local.admin_name}-role"
  assume_role_policy = data.aws_iam_policy_document.admin_ec2_assume.json
  tags               = var.default_tags
}

# Enables SSM Session Manager; the box has no inbound ports.
resource "aws_iam_role_policy_attachment" "admin_ssm_core" {
  provider   = aws.aws
  role       = aws_iam_role.admin_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "admin_s3" {
  statement {
    sid     = "ListBuckets"
    effect  = "Allow"
    actions = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [
      "arn:aws:s3:::usgs-landsat",
      "arn:aws:s3:::copernicus-dem-30m",
      "arn:aws:s3:::e84-earth-search-sentinel-data",
      module.s3_bucket.public_bucket_arn,
    ]
  }

  statement {
    sid     = "ReadObjects"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::usgs-landsat/*",
      "arn:aws:s3:::copernicus-dem-30m/*",
      "arn:aws:s3:::e84-earth-search-sentinel-data/*",
    ]
  }

  statement {
    sid       = "ReadWriteObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${module.s3_bucket.public_bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "admin_s3" {
  provider = aws.aws
  name     = "${local.admin_name}-s3"
  role     = aws_iam_role.admin_instance.id
  policy   = data.aws_iam_policy_document.admin_s3.json
}

# Cross-account pull also requires the ECR repository policy in the hub account
# (686410905891) to allow this account. Pushing needs ecr:PutImage /
# UploadLayerPart added here and in that repo policy.
data "aws_iam_policy_document" "admin_ecr" {
  statement {
    sid       = "EcrAuthToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "EcrPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = ["arn:aws:ecr:${local.admin_region}:686410905891:repository/*"]
  }
}

resource "aws_iam_role_policy" "admin_ecr" {
  #checkov:skip=CKV_AWS_355:ecr:GetAuthorizationToken requires Resource="*" by API design.
  provider = aws.aws
  name     = "${local.admin_name}-ecr-pull"
  role     = aws_iam_role.admin_instance.id
  policy   = data.aws_iam_policy_document.admin_ecr.json
}

resource "aws_iam_instance_profile" "admin" {
  provider = aws.aws
  name     = "${local.admin_name}-profile"
  role     = aws_iam_role.admin_instance.name
  tags     = var.default_tags
}

# ============================================================
# Network
# ============================================================

resource "aws_security_group" "admin" {
  #checkov:skip=CKV_AWS_382:Egress-all required for OS/package/Docker/ECR pulls and SSM endpoints. No inbound is allowed.
  provider    = aws.aws
  name_prefix = "${local.admin_name}-"
  description = "Admin workstation: no inbound (SSM-only), all outbound"
  vpc_id      = module.networks.vpc_id

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.default_tags, {
    Name = "${local.admin_name}-sg"
  })
}

# Grant this box NFS access on the shared EFS security group.
resource "aws_security_group_rule" "admin_efs_ingress" {
  provider                 = aws.aws
  description              = "NFS from admin workstation"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = module.eks-cluster.efs_security_group_id
  source_security_group_id = aws_security_group.admin.id
}

# ============================================================
# Cloud-init
# ============================================================

data "cloudinit_config" "admin" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = <<-YAML
      #cloud-config
      package_update: true
      package_upgrade: true

      packages:
        - ca-certificates
        - curl
        - unzip
        - git
        - jq
        - gnupg
        - lsb-release
        - make
        - gcc
        - g++
        - build-essential
        - python3
        - python3-pip
        - python3-venv
        - software-properties-common
        - apt-transport-https
        - htop
        - tmux
        - ripgrep
        - fzf
        - tar
        - gzip
        - nfs-common

      runcmd:
        # ---- Wait for apt locks to clear ----
        - [ bash, -lc, "set -euo pipefail; for i in $(seq 1 60); do if fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || fuser /var/cache/apt/archives/lock >/dev/null 2>&1; then echo \"apt lock present, waiting... ($i)\"; sleep 2; else break; fi; done" ]

        # ---- SSM Agent (ensure the snap is running) ----
        - [ bash, -lc, "set -euo pipefail; snap install amazon-ssm-agent --classic || true" ]
        - [ bash, -lc, "set -euo pipefail; snap start amazon-ssm-agent || systemctl enable --now amazon-ssm-agent || systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service || true" ]

        # ---- AWS CLI v2 ----
        - [ bash, -lc, "set -euo pipefail; cd /tmp && curl -sSLo awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" ]
        - [ bash, -lc, "set -euo pipefail; cd /tmp && unzip -q awscliv2.zip && /tmp/aws/install --update" ]

        # ---- Docker Engine + buildx + compose plugin ----
        - [ bash, -lc, "set -euo pipefail; install -m 0755 -d /etc/apt/keyrings" ]
        - [ bash, -lc, "set -euo pipefail; curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg" ]
        - [ bash, -lc, "set -euo pipefail; chmod a+r /etc/apt/keyrings/docker.gpg" ]
        - [ bash, -lc, "set -euo pipefail; echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable\" > /etc/apt/sources.list.d/docker.list" ]
        - [ bash, -lc, "set -euo pipefail; apt-get update -y" ]
        - [ bash, -lc, "set -euo pipefail; apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin" ]
        - [ bash, -lc, "systemctl enable --now docker" ]
        - [ bash, -lc, "usermod -aG docker ubuntu" ]

        # ---- ECR credential helper for the hub registry ----
        - [ bash, -lc, "set -euo pipefail; apt-get install -y amazon-ecr-credential-helper || true" ]
        - [ bash, -lc, "set -euo pipefail; install -d -o ubuntu -g ubuntu /home/ubuntu/.docker; echo '{\"credHelpers\":{\"686410905891.dkr.ecr.${local.admin_region}.amazonaws.com\":\"ecr-login\"}}' > /home/ubuntu/.docker/config.json; chown ubuntu:ubuntu /home/ubuntu/.docker/config.json" ]

        # ---- GitHub CLI ----
        - [ bash, -lc, "set -euo pipefail; curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && chmod a+r /etc/apt/keyrings/githubcli-archive-keyring.gpg" ]
        - [ bash, -lc, "set -euo pipefail; echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" > /etc/apt/sources.list.d/github-cli.list" ]
        - [ bash, -lc, "set -euo pipefail; apt-get update -y && apt-get install -y gh" ]

        # ---- uv ----
        - [ bash, -lc, "set -euo pipefail; sudo -u ubuntu -H bash -lc 'curl -fsSL https://astral.sh/uv/install.sh | sh'" ]
        - [ bash, -lc, "set -euo pipefail; grep -qxF 'export PATH=\"$HOME/.local/bin:$PATH\"' /home/ubuntu/.bashrc || echo 'export PATH=\"$HOME/.local/bin:$PATH\"' >> /home/ubuntu/.bashrc" ]

        # ---- Starship prompt ----
        - [ bash, -lc, "set -euo pipefail; curl -fsSL https://starship.rs/install.sh | sh -s -- -y" ]
        - [ bash, -lc, "set -euo pipefail; sudo -u ubuntu -H bash -lc 'mkdir -p ~/.config && starship preset no-empty-icons -o ~/.config/starship.toml'" ]
        - [ bash, -lc, "set -euo pipefail; grep -qxF 'eval \"$(starship init bash)\"' /home/ubuntu/.bashrc || echo 'eval \"$(starship init bash)\"' >> /home/ubuntu/.bashrc" ]

        # ---- Mount EFS filesystem root at /mnt/efs ----
        - [ bash, -lc, "set -euo pipefail; mkdir -p /mnt/efs" ]
        - [ bash, -lc, "set -euo pipefail; grep -q '${local.efs_dns}' /etc/fstab || echo '${local.efs_dns}:/ /mnt/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0' >> /etc/fstab" ]
        - [ bash, -lc, "set -euo pipefail; for i in $(seq 1 12); do mount /mnt/efs && break || (echo \"efs mount retry $i\"; sleep 5); done" ]

        - [ bash, -lc, "grep -qxF 'export EDITOR=vim' /home/ubuntu/.bashrc || echo 'export EDITOR=vim' >> /home/ubuntu/.bashrc" ]
        - [ bash, -lc, "chown ubuntu:ubuntu /home/ubuntu/.bashrc" ]
    YAML
  }
}

# ============================================================
# Instance
# ============================================================

data "aws_ami" "admin_ubuntu" {
  provider    = aws.aws
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "admin" {
  #checkov:skip=CKV_AWS_135:ebs_optimized is set; skip is for the data-source-derived default check.
  provider      = aws.aws
  ami           = data.aws_ami.admin_ubuntu.id
  instance_type = local.admin_instance_type
  subnet_id     = module.networks.private_subnets[0]

  associate_public_ip_address = false
  monitoring                  = true
  ebs_optimized               = true

  iam_instance_profile   = aws_iam_instance_profile.admin.name
  vpc_security_group_ids = [aws_security_group.admin.id]

  user_data_base64 = data.cloudinit_config.admin.rendered

  root_block_device {
    volume_size = local.admin_root_volume_gb
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.default_tags, {
    Name      = local.admin_name
    NodeGroup = "Admin-Workstation"
  })

  lifecycle {
    ignore_changes = [ami, user_data_base64, subnet_id]
  }
}

# ============================================================
# Nightly autostop (19:00 WIB / 12:00 UTC)
# ============================================================

data "aws_iam_policy_document" "admin_eventbridge_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "admin_autostop" {
  provider           = aws.aws
  name               = "${local.admin_name}-autostop"
  assume_role_policy = data.aws_iam_policy_document.admin_eventbridge_assume.json
  tags               = var.default_tags
}

resource "aws_iam_role_policy" "admin_autostop" {
  #checkov:skip=CKV_AWS_290:ssm:StartAutomationExecution + ec2:StopInstances require wildcard resources.
  #checkov:skip=CKV_AWS_355:Resource="*" required for SSM automation execution and EC2 stop.
  provider = aws.aws
  name     = "${local.admin_name}-autostop"
  role     = aws_iam_role.admin_autostop.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:StartAutomationExecution"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances", "ec2:StopInstances"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "admin_nightly_stop" {
  provider            = aws.aws
  name                = "${local.admin_name}-nightly-stop"
  description         = "Stop admin workstation nightly at 19:00 WIB (12:00 UTC)"
  schedule_expression = "cron(0 12 * * ? *)"
  tags                = var.default_tags
}

resource "aws_cloudwatch_event_target" "admin_nightly_stop" {
  provider = aws.aws
  rule     = aws_cloudwatch_event_rule.admin_nightly_stop.name
  arn      = "arn:aws:ssm:${local.admin_region}::automation-definition/AWS-StopEC2Instance:$DEFAULT"
  role_arn = aws_iam_role.admin_autostop.arn

  input = jsonencode({
    InstanceId = [aws_instance.admin.id]
  })
}
