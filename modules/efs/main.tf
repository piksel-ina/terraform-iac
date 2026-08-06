resource "aws_security_group" "efs" {
  name_prefix = "${var.cluster_name}-efs-"
  description = "EFS mount target access from EKS cluster nodes."
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.default_tags, {
    Name = "${var.cluster_name}-efs-sg"
  })
}

resource "aws_security_group_rule" "efs_ingress_nodes" {
  description              = "NFS traffic from EKS cluster nodes"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = var.node_security_group_id
}

resource "aws_security_group_rule" "efs_egress_all" {
  #checkov:skip=CKV_AWS_382:NFS mount targets require unrestricted egress for lifecycle operations.
  description       = "Allow all outbound traffic from EFS"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs.id
}

resource "aws_efs_file_system" "data" {
  #checkov:skip=CKV_AWS_184:Uses AWS-managed encryption. CMK to be considered for future compliance.
  creation_token   = "${var.cluster_name}-efs"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia_days
  }

  tags = merge(var.default_tags, {
    Name = "${var.cluster_name}-efs"
  })
}

resource "aws_efs_mount_target" "data" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.data.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_backup_policy" "data" {
  file_system_id = aws_efs_file_system.data.id

  backup_policy {
    status = var.backup_enabled ? "ENABLED" : "DISABLED"
  }
}

resource "aws_iam_role" "csi" {
  name = "${var.cluster_name}-efs-csi"

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

resource "aws_iam_role_policy_attachment" "csi" {
  role       = aws_iam_role.csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

resource "aws_eks_pod_identity_association" "csi" {
  cluster_name    = var.cluster_name
  namespace       = var.csi_service_account.namespace
  service_account = var.csi_service_account.name
  role_arn        = aws_iam_role.csi.arn
}
