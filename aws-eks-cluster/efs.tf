# --- IRSA ---
module "efs_csi_irsa_role" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version               = "5.55.0"
  role_name             = "${local.cluster}-efs-csi"
  attach_efs_csi_policy = true

  role_policy_arns = {
    EFSClientWrite = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
  }

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

# --- Security group for EFS ---
resource "aws_security_group" "efs" {
  name_prefix = "${local.cluster}-efs-"
  description = "Security group for EFS file system access from EKS cluster"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.tags, {
    Name = "${local.cluster}-efs-sg"
  })
}

resource "aws_security_group_rule" "efs_ingress_nodes" {
  description              = "NFS traffic from EKS cluster nodes"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = module.eks.node_security_group_id
}

resource "aws_security_group_rule" "efs_egress_all" {
  #checkov:skip=CKV_AWS_382:Standard unrestricted egress for EFS. NFS mount requires outbound connectivity.
  description       = "Allow all outbound traffic from EFS"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs.id
}

# --- EFS File System ---
resource "aws_efs_file_system" "data" {
  #checkov:skip=CKV_AWS_184:Uses AWS-managed encryption (encrypted=true). CMK to be considered for future compliance.
  creation_token   = "${local.cluster}-efs"
  encrypted        = true
  performance_mode = "generalPurpose"

  throughput_mode = "bursting" # or "elastic"/"provisioned"
  # provisioned_throughput_in_mibps = 100 # Uncomment and set if using "provisioned"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(local.tags, {
    Name = "${local.cluster}-efs"
  })
}

# --- EFS Mount Targets ---
resource "aws_efs_mount_target" "data" {
  count           = length(var.private_subnets_ids)
  file_system_id  = aws_efs_file_system.data.id
  subnet_id       = var.private_subnets_ids[count.index]
  security_groups = [aws_security_group.efs.id]


  depends_on = [aws_efs_file_system.data, aws_security_group.efs]
}

# Note: EFS access point removed - using existing fsap-0126d051fe0f291c3 in cluster-addons

resource "aws_efs_access_point" "coastlines" {
  file_system_id = aws_efs_file_system.data.id

  posix_user {
    uid = 1000
    gid = 2000
  }

  root_directory {
    path = "/data/coastlines"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 2000
      permissions = "0770"
    }
  }

  tags = merge(local.tags, {
    Name = "${local.cluster}-efs-ap-coastlines"
  })
}

# --- Enable EFS Backup ---
resource "aws_efs_backup_policy" "data" {
  file_system_id = aws_efs_file_system.data.id

  backup_policy {
    status = var.efs_backup_enabled ? "ENABLED" : "DISABLED"
  }
}
