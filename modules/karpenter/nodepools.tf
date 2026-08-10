locals {
  karpenter_deps = [
    helm_release.karpenter,
    time_sleep.wait_for_karpenter_crds,
  ]

  jupyter_r_family_pools = {
    medium = {
      size    = "xlarge"
      taint   = "medium"
      profile = "medium"
    }
    large = {
      size    = "2xlarge"
      taint   = "large"
      profile = "large"
    }
    very-large = {
      size    = "4xlarge"
      taint   = "very-large"
      profile = "very-large"
    }
    ultra = {
      size    = "8xlarge"
      taint   = "ultra"
      profile = "ultra"
    }
  }

  data_production_pools = {
    r4xlarge  = "4xlarge"
    r8xlarge  = "8xlarge"
    r12xlarge = "12xlarge"
    r16xlarge = "16xlarge"
  }
}

# --- Default NodeClass + NodePool ---

resource "kubectl_manifest" "default_node_class" {
  depends_on = [helm_release.karpenter, time_sleep.wait_for_karpenter_crds]

  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name   = "default"
      labels = { "app.kubernetes.io/managed-by" = "terraform" }
    }
    spec = {
      amiFamily        = "AL2023"
      role             = module.controller.node_iam_role_name
      amiSelectorTerms = [{ alias = var.default_ami_alias }]
      blockDeviceMappings = [{
        deviceName = "/dev/xvda"
        ebs = {
          volumeSize = "120Gi"
          volumeType = "gp3"
          encrypted  = true
        }
      }]
      subnetSelectorTerms = [{
        tags = {
          "karpenter.sh/discovery" = var.cluster_name
          SubnetType               = "Private"
        }
      }]
      associatePublicIPAddress = false
      securityGroupSelectorTerms = [{
        tags = { "karpenter.sh/discovery" = var.cluster_name }
      }]
      tags = { NodeGroup = "Others" }
    }
  })
}

resource "kubectl_manifest" "default_node_pool" {
  depends_on = [kubectl_manifest.default_node_class]

  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name   = "default"
      labels = { "app.kubernetes.io/managed-by" = "terraform" }
    }
    spec = {
      template = {
        spec = {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "default"
          }
          requirements = [
            { key = "karpenter.k8s.aws/instance-category", operator = "In", values = ["c", "t"] },
            { key = "karpenter.k8s.aws/instance-hypervisor", operator = "In", values = ["nitro"] },
            { key = "karpenter.k8s.aws/instance-generation", operator = "Gt", values = ["2"] },
            { key = "kubernetes.io/arch", operator = "In", values = ["amd64"] },
          ]
        }
      }
      limits = { cpu = var.default_nodepool_cpu_limit }
      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "20m"
        expireAfter         = "720h"
        budgets = [
          { nodes = "10%", schedule = "0 1 * * mon-fri", duration = "11h", reasons = ["Underutilized", "Empty"] },
          { nodes = "30%", schedule = "0 13 * * *", duration = "11h", reasons = ["Underutilized", "Empty", "Drifted"] },
          { nodes = "40%", schedule = "0 0 * * sat", duration = "24h", reasons = ["Underutilized", "Empty", "Drifted"] },
          { nodes = "40%", schedule = "0 0 * * sun", duration = "24h", reasons = ["Underutilized", "Empty", "Drifted"] },
        ]
      }
    }
  })
}

# --- GPU NodeClass + NodePool ---

resource "kubectl_manifest" "gpu_node_class" {
  depends_on = [helm_release.karpenter, time_sleep.wait_for_karpenter_crds]

  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata   = { name = "gpu" }
    spec = {
      amiFamily        = "AL2023"
      role             = module.controller.node_iam_role_name
      amiSelectorTerms = [{ name = var.gpu_ami_name }]
      blockDeviceMappings = [{
        deviceName = "/dev/xvda"
        ebs = {
          volumeSize = "120Gi"
          volumeType = "gp3"
          encrypted  = true
        }
      }]
      subnetSelectorTerms = [{
        tags = {
          "karpenter.sh/discovery" = var.cluster_name
          SubnetType               = "Private"
        }
      }]
      associatePublicIPAddress = false
      securityGroupSelectorTerms = [{
        tags = { "karpenter.sh/discovery" = var.cluster_name }
      }]
      tags = { NodeGroup = "GPU" }
    }
  })
}

resource "kubectl_manifest" "gpu_node_pool" {
  depends_on = [kubectl_manifest.gpu_node_class]

  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name   = "gpu"
      labels = { "app.kubernetes.io/managed-by" = "terraform" }
    }
    spec = {
      template = {
        spec = {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "gpu"
          }
          requirements = [{
            key      = "node.kubernetes.io/instance-type"
            operator = "In"
            values   = ["g5.xlarge", "g5.2xlarge", "g5.4xlarge", "g5.8xlarge", "g5.12xlarge"]
          }]
          taints = [{
            key    = "nvidia.com/gpu"
            value  = "true"
            effect = "NoSchedule"
          }]
        }
      }
      limits = { gpu = var.gpu_nodepool_limit }
      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "20m"
      }
    }
  })
}

# --- Jupyter Sandbox NodeClasses (standard tier + advanced tiers) ---

resource "kubectl_manifest" "jupyter_standard_node_class" {
  depends_on = [helm_release.karpenter, time_sleep.wait_for_karpenter_crds]

  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name   = "jupyter"
      labels = { "app.kubernetes.io/managed-by" = "terraform" }
    }
    spec = {
      amiFamily        = "AL2023"
      role             = module.controller.node_iam_role_name
      amiSelectorTerms = [{ alias = var.default_ami_alias }]
      blockDeviceMappings = [{
        deviceName = "/dev/xvda"
        ebs = {
          volumeSize          = "40Gi"
          volumeType          = "gp3"
          encrypted           = true
          deleteOnTermination = true
        }
      }]
      subnetSelectorTerms = [{
        tags = {
          "karpenter.sh/discovery" = var.cluster_name
          SubnetType               = "Private"
        }
      }]
      associatePublicIPAddress = false
      securityGroupSelectorTerms = [{
        tags = { "karpenter.sh/discovery" = var.cluster_name }
      }]
      tags = {
        NodeGroup = "Jupyter-Sandboxes"
        User-type = "Standard-Users"
      }
    }
  })
}

resource "kubectl_manifest" "jupyter_advanced_node_class" {
  depends_on = [helm_release.karpenter, time_sleep.wait_for_karpenter_crds]

  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name   = "dev-jupyter"
      labels = { "app.kubernetes.io/managed-by" = "terraform" }
    }
    spec = {
      amiFamily        = "AL2023"
      role             = module.controller.node_iam_role_name
      amiSelectorTerms = [{ alias = var.default_ami_alias }]
      blockDeviceMappings = [{
        deviceName = "/dev/xvda"
        ebs = {
          volumeSize          = "80Gi"
          volumeType          = "gp3"
          encrypted           = true
          deleteOnTermination = true
        }
      }]
      subnetSelectorTerms = [{
        tags = {
          "karpenter.sh/discovery" = var.cluster_name
          SubnetType               = "Private"
        }
      }]
      associatePublicIPAddress = false
      securityGroupSelectorTerms = [{
        tags = { "karpenter.sh/discovery" = var.cluster_name }
      }]
      tags = {
        NodeGroup = "Jupyter-Sandboxes"
        User-type = "Advanced-Users"
      }
    }
  })
}

# --- Jupyter NodePools ---

resource "kubectl_manifest" "jupyter_standard_node_pool" {
  depends_on = [kubectl_manifest.jupyter_standard_node_class]

  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name   = "jupyter-standard"
      labels = { "app.kubernetes.io/managed-by" = "terraform" }
    }
    spec = {
      template = {
        metadata = { labels = { jupyter-profile = "standard" } }
        spec = {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "jupyter"
          }
          taints = [{
            key    = "jupyter-profile"
            value  = "standard"
            effect = "NoSchedule"
          }]
          requirements = [
            { key = "karpenter.sh/capacity-type", operator = "In", values = ["on-demand"] },
            { key = "kubernetes.io/arch", operator = "In", values = ["amd64"] },
            { key = "kubernetes.io/os", operator = "In", values = ["linux"] },
            { key = "karpenter.k8s.aws/instance-family", operator = "In", values = ["m7", "m6", "m5", "m6i", "m6a", "m7i"] },
            { key = "karpenter.k8s.aws/instance-size", operator = "In", values = ["xlarge"] },
          ]
        }
      }
      limits = { cpu = var.default_nodepool_cpu_limit }
      disruption = {
        consolidationPolicy = "WhenEmpty"
        consolidateAfter    = "5m"
        expireAfter         = "168h"
        budgets             = [{ nodes = "100%" }]
      }
    }
  })
}

resource "kubectl_manifest" "jupyter_r_family_node_pool" {
  for_each   = local.jupyter_r_family_pools
  depends_on = [kubectl_manifest.jupyter_advanced_node_class]

  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name   = "jupyter-${each.key}"
      labels = { "app.kubernetes.io/managed-by" = "terraform" }
    }
    spec = {
      template = {
        metadata = { labels = { jupyter-profile = each.value.profile } }
        spec = {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "dev-jupyter"
          }
          taints = [{
            key    = "jupyter-profile"
            value  = each.value.taint
            effect = "NoSchedule"
          }]
          requirements = [
            { key = "karpenter.sh/capacity-type", operator = "In", values = ["on-demand"] },
            { key = "kubernetes.io/arch", operator = "In", values = ["amd64"] },
            { key = "kubernetes.io/os", operator = "In", values = ["linux"] },
            { key = "karpenter.k8s.aws/instance-family", operator = "In", values = ["r7i", "r6i", "r5"] },
            { key = "karpenter.k8s.aws/instance-size", operator = "In", values = [each.value.size] },
          ]
        }
      }
      limits = { cpu = var.default_nodepool_cpu_limit }
      disruption = {
        consolidationPolicy = "WhenEmpty"
        consolidateAfter    = "5m"
        expireAfter         = "168h"
        budgets             = [{ nodes = "100%" }]
      }
    }
  })
}

# --- Data Production NodeClass + NodePools ---

resource "kubectl_manifest" "data_production_node_class" {
  depends_on = [helm_release.karpenter, time_sleep.wait_for_karpenter_crds]

  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name   = "data-production"
      labels = { "app.kubernetes.io/managed-by" = "terraform" }
    }
    spec = {
      amiFamily        = "AL2023"
      role             = module.controller.node_iam_role_name
      amiSelectorTerms = [{ alias = var.default_ami_alias }]
      blockDeviceMappings = [{
        deviceName = "/dev/xvda"
        ebs = {
          volumeSize          = "30Gi"
          volumeType          = "gp3"
          encrypted           = true
          deleteOnTermination = true
        }
      }]
      subnetSelectorTerms = [{
        tags = {
          "karpenter.sh/discovery" = var.cluster_name
          SubnetType               = "Public"
        }
      }]
      associatePublicIPAddress = true
      securityGroupSelectorTerms = [{
        tags = { "karpenter.sh/discovery" = var.cluster_name }
      }]
      tags = { NodeGroup = "Data-Production" }
    }
  })
}

resource "kubectl_manifest" "data_production_node_pool" {
  for_each   = local.data_production_pools
  depends_on = [kubectl_manifest.data_production_node_class]

  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name   = "data-production-${each.key}"
      labels = { "app.kubernetes.io/managed-by" = "terraform" }
    }
    spec = {
      template = {
        metadata = { labels = { data-production = each.key } }
        spec = {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "data-production"
          }
          taints = [{
            key    = "data-production"
            value  = each.key
            effect = "NoSchedule"
          }]
          requirements = [
            { key = "karpenter.sh/capacity-type", operator = "In", values = ["spot", "on-demand"] },
            { key = "kubernetes.io/arch", operator = "In", values = ["amd64"] },
            { key = "kubernetes.io/os", operator = "In", values = ["linux"] },
            { key = "karpenter.k8s.aws/instance-family", operator = "In", values = ["r7i", "r6i", "r5"] },
            { key = "karpenter.k8s.aws/instance-size", operator = "In", values = [each.value] },
          ]
        }
      }
      limits = { cpu = var.data_production_cpu_limit }
      disruption = {
        consolidationPolicy = "WhenEmpty"
        consolidateAfter    = "5m"
        expireAfter         = "168h"
        budgets             = [{ nodes = "100%" }]
      }
    }
  })
}
