locals {
  system_node_common = {
    ami_type                   = "AL2023_x86_64_STANDARD"
    disk_size                  = 20
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
    tags = merge(var.default_tags, { NodeGroup = "System" })
  }

  system_node_groups = {
    on-demand = merge(local.system_node_common, {
      name           = "system-on-demand"
      capacity_type  = "ON_DEMAND"
      instance_types = [var.system_node_instance_types.on_demand]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    })
    spot = merge(local.system_node_common, {
      name           = "system-spot"
      capacity_type  = "SPOT"
      instance_types = var.system_node_instance_types.spot
      min_size       = 1
      max_size       = 4
      desired_size   = 1
    })
  }

  access_entries = merge(
    {
      admin = {
        kubernetes_groups = []
        principal_arn     = var.sso_admin_role_arn
        policy_associations = {
          cluster_admin = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
    },
    {
      for k, v in var.additional_access_entries : k => {
        kubernetes_groups = v.kubernetes_groups
        principal_arn     = v.principal_arn
        policy_associations = {
          access = {
            policy_arn = v.policy_arn
            access_scope = {
              type = v.access_scope_type
            }
          }
        }
      }
    }
  )
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.24"

  name               = var.cluster_name
  kubernetes_version = var.eks_version

  endpoint_public_access       = var.endpoint_public_access
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  enabled_log_types = ["api", "authenticator", "controllerManager", "scheduler"]

  addons = {
    coredns = {
      addon_version = var.coredns_version
      configuration_values = jsonencode({
        autoScaling = {
          enabled     = true
          minReplicas = 2
          maxReplicas = 10
        }
        resources = {
          requests = { cpu = "150m", memory = "125M" }
          limits   = { cpu = "1000m", memory = "250M" }
        }
      })
    }
    kube-proxy = {
      addon_version  = var.kube_proxy_version
      before_compute = true
    }
    vpc-cni = {
      addon_version  = var.vpc_cni_version
      before_compute = true
      pod_identity_association = [{
        role_arn        = aws_iam_role.vpc_cni.arn
        service_account = "aws-node"
      }]
    }
    aws-ebs-csi-driver = {
      addon_version               = var.ebs_csi_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      pod_identity_association = [{
        role_arn        = aws_iam_role.ebs_csi.arn
        service_account = "ebs-csi-controller-sa"
      }]
    }
    eks-pod-identity-agent = {
      addon_version               = var.pod_identity_version
      before_compute              = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }

  eks_managed_node_groups = local.system_node_groups

  enable_cluster_creator_admin_permissions = false
  access_entries                           = local.access_entries

  node_security_group_additional_rules = {
    egress_dns_tcp = {
      description = "Allow outbound DNS TCP for external-dns"
      protocol    = "tcp"
      from_port   = 53
      to_port     = 53
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  node_security_group_tags = merge(var.default_tags, {
    "karpenter.sh/discovery" = var.cluster_name
  })

  tags = var.default_tags
}
