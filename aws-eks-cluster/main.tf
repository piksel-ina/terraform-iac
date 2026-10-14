locals {
  cluster = var.cluster_name
  tags    = var.default_tags
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

# --- Create Cluster ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.24.0"

  name                   = local.cluster
  kubernetes_version     = var.eks-version
  endpoint_public_access = true

  # EKS Addons
  addons = {
    coredns = {
      addon_version = var.coredns-version
      configuration_values = jsonencode({
        autoScaling = {
          enabled     = true
          minReplicas = 2
          maxReplicas = 10
        }
        resources = {
          requests = {
            cpu    = "150m"
            memory = "125M"
          }
          limits = {
            cpu    = "1000m"
            memory = "250M"
          }
        }
      })
    }
    kube-proxy = {
      addon_version = var.kube-proxy-version
    }
    vpc-cni = {
      addon_version            = var.vpc-cni-version
      service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn
    }
    aws-ebs-csi-driver = {
      addon_version               = var.ebs-csi-version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = module.ebs_csi_irsa_role.iam_role_arn
    }
    eks-pod-identity-agent = {
      addon_version               = var.pod-identity-version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets_ids

  enabled_log_types = ["api", "authenticator", "controllerManager", "scheduler"]

  # --- EKS Managed Node Groups ---
  eks_managed_node_groups = {
    # 1 On-Demand for system reliability
    systems = {
      name = "system-v1"

      min_size     = 1
      max_size     = 2
      desired_size = 1

      capacity_type  = "ON_DEMAND"
      instance_types = ["t3.large"]
      ami_type       = "AL2023_x86_64_STANDARD"
      disk_size      = 20

      iam_role_attach_cni_policy = true
      iam_role_additional_policies = {
        AssumeECRRole                      = aws_iam_policy.assume_ecr_role.arn
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }

      labels = {
        "karpenter.sh/controller" = "true"
      }

      taints = {
        CriticalAddonsOnly = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }

      tags = merge(local.tags, {
        NodeGroup = "System"
      })
    }

    # Spot node group for cost savings
    system-spots = {
      name = "system-spot-v1"

      min_size     = 1
      max_size     = 4
      desired_size = 1

      capacity_type  = "SPOT"
      instance_types = ["t3.medium", "t3.large", "c5.large", "c5d.large", "m5.large", "m5d.large"]
      ami_type       = "AL2023_x86_64_STANDARD"
      disk_size      = 20

      iam_role_attach_cni_policy = true
      iam_role_additional_policies = {
        AssumeECRRole                      = aws_iam_policy.assume_ecr_role.arn
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }

      labels = {
        "karpenter.sh/controller" = "true"
      }

      taints = {
        CriticalAddonsOnly = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }

      tags = merge(local.tags, {
        NodeGroup = "System"
      })
    }
  }

  # Enable cluster access
  enable_cluster_creator_admin_permissions = false
  access_entries = {
    admin-access = {
      kubernetes_groups = []
      principal_arn     = var.sso-admin-role-arn

      policy_associations = {
        single = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    codebuild-access = {
      kubernetes_groups = []
      principal_arn     = var.codebuild_role_arn

      policy_associations = {
        single = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Additional Node Security Groups:
  node_security_group_additional_rules = {
    # Allow outbound DNS for External DNS
    egress_dns_tcp = {
      description = "Allow outbound DNS TCP"
      protocol    = "tcp"
      from_port   = 53
      to_port     = 53
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  node_security_group_tags = merge(local.tags, {
    "karpenter.sh/discovery" = local.cluster
  })

  tags = local.tags
}
