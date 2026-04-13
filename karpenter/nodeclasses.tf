######################################################
# --- Default Nodeclass ---
######################################################

resource "kubectl_manifest" "karpenter_node_class" {
  depends_on = [
    helm_release.karpenter,
    time_sleep.wait_for_karpenter
  ]

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: default
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      amiFamily: AL2023
      role: ${module.karpenter.node_iam_role_name}
      amiSelectorTerms:
        - alias: ${var.default_nodepool_ami_alias}
      blockDeviceMappings:
        - deviceName: /dev/xvda
          ebs:
            volumeSize: 120Gi
            volumeType: gp3
            encrypted: true
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.cluster}
            SubnetType: "Private"
      associatePublicIPAddress: false
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.cluster}
      tags:
        NodeGroup: "Others"
  YAML
}

# --- Default NodePool ---
resource "kubectl_manifest" "karpenter_node_pool" {
  depends_on = [kubectl_manifest.karpenter_node_class]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: default
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      template:
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: default
          requirements:
            - key: karpenter.k8s.aws/instance-category
              operator: In
              values: ["c", "t" ]
            - key: karpenter.k8s.aws/instance-hypervisor
              operator: In
              values: ["nitro"]
            - key: karpenter.k8s.aws/instance-generation
              operator: Gt
              values: ["2"]
            - key: kubernetes.io/arch
              operator: In
              values: ["amd64"]
      limits:
        cpu: ${var.default_nodepool_node_limit}

      disruption:
        consolidationPolicy: WhenEmptyOrUnderutilized
        consolidateAfter: 20m
        expireAfter: 720h

        budgets:
          # Business hours: 8am-7pm GMT+7 (1am-12pm UTC) - Conservative
          - nodes: "10%"
            schedule: "0 1 * * mon-fri"
            duration: "11h"
            reasons:
              - "Underutilized"
              - "Empty"

          # Night hours: 8pm-7am GMT+7 - More aggressive
          - nodes: "30%"
            schedule: "0 13 * * *"
            duration: "11h"
            reasons:
              - "Underutilized"
              - "Empty"
              - "Drifted"

          # Saturday: All day
          - nodes: "40%"
            schedule: "0 0 * * sat"
            duration: "24h"
            reasons:
              - "Underutilized"
              - "Empty"
              - "Drifted"

          # Sunday: All day
          - nodes: "40%"
            schedule: "0 0 * * sun"
            duration: "24h"
            reasons:
              - Underutilized
              - "Empty"
              - "Drifted"
  YAML
}

######################################################
# --- GPU NodeClass ---
######################################################
resource "kubectl_manifest" "karpenter_gpu_node_class" {
  depends_on = [
    helm_release.karpenter,
    time_sleep.wait_for_karpenter
  ]

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: gpu
    spec:
      amiFamily: AL2023
      role: ${module.karpenter.node_iam_role_name}
      amiSelectorTerms:
        - name: ${var.gpu_nodepool_ami}
      blockDeviceMappings:
        - deviceName: /dev/xvda
          ebs:
            volumeSize: 120Gi
            volumeType: gp3
            encrypted: true
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.cluster}
            SubnetType: "Private"
      associatePublicIPAddress: false
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.cluster}
      tags:
        NodeGroup: "GPU"
  YAML
}

#--- GPU Intensive Nodepool --
resource "kubectl_manifest" "karpenter_node_pool_gpu" {
  depends_on = [kubectl_manifest.karpenter_gpu_node_class]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: gpu
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      template:
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: gpu
          requirements:
            - key: node.kubernetes.io/instance-type
              operator: In
              values: ["g5.xlarge", "g5.2xlarge", "g5.4xlarge", "g5.8xlarge", "g5.12xlarge"]
          taints:
            - key: nvidia.com/gpu
              value: "true"
              effect: NoSchedule
      limits:
        gpu: ${var.gpu_nodepool_node_limit}
      disruption:
        consolidationPolicy: WhenEmptyOrUnderutilized
        consolidateAfter: 20m
  YAML
}


######################################################
# ------ General Use NodeClass for Jupyter Sandboxes ------
######################################################
resource "kubectl_manifest" "karpenter_node_class_jupyter" {
  depends_on = [
    helm_release.karpenter,
    time_sleep.wait_for_karpenter
  ]

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: jupyter
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      amiFamily: AL2023
      role: ${module.karpenter.node_iam_role_name}
      amiSelectorTerms:
        - alias: ${var.default_nodepool_ami_alias}
      blockDeviceMappings:
        - deviceName: /dev/xvda
          ebs:
            volumeSize: 40Gi
            volumeType: gp3
            encrypted: true
            deleteOnTermination: true
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.cluster}
            SubnetType: "Private"
      associatePublicIPAddress: false
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.cluster}
      tags:
        NodeGroup: "Jupyter-Sandboxes"
        User-type: "Standard-Users"
  YAML
}

# --- Standard NodePool ---
resource "kubectl_manifest" "karpenter_node_pool_jupyter_standard" {
  depends_on = [kubectl_manifest.karpenter_node_class_jupyter]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: jupyter-standard
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      template:
        metadata:
          labels:
            jupyter-profile: standard
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: jupyter

          taints:
            - key: jupyter-profile
              value: standard
              effect: NoSchedule

          requirements:
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["spot", "on-demand"]

            - key: kubernetes.io/arch
              operator: In
              values: ["amd64"]

            - key: kubernetes.io/os
              operator: In
              values: ["linux"]

            - key: karpenter.k8s.aws/instance-family
              operator: In
              values: ["m7", "m6", "m5", "m6i", "m6a", "m7i"]

            - key: karpenter.k8s.aws/instance-size
              operator: In
              values: ["xlarge"]

      limits:
        cpu: ${var.default_nodepool_node_limit}

      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 5m
        expireAfter: 168h

        budgets:
          - nodes: "100%"
  YAML
}

######################################################
# --- Development NodeClass for Jupyter Sandboxes ------
######################################################
resource "kubectl_manifest" "karpenter_node_class_develop_jupyter" {
  depends_on = [
    helm_release.karpenter,
    time_sleep.wait_for_karpenter
  ]

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: dev-jupyter
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      amiFamily: AL2023
      role: ${module.karpenter.node_iam_role_name}
      amiSelectorTerms:
        - alias: ${var.default_nodepool_ami_alias}
      blockDeviceMappings:
        - deviceName: /dev/xvda
          ebs:
            volumeSize: 80Gi
            volumeType: gp3
            encrypted: true
            deleteOnTermination: true
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.cluster}
            SubnetType: "Private"
      associatePublicIPAddress: false
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.cluster}
      tags:
        NodeGroup: "Jupyter-Sandboxes"
        User-type: "Advanced-Users"
  YAML
}

# --- Medium NodePool ---
resource "kubectl_manifest" "karpenter_node_pool_develop_jupyter_medium" {
  depends_on = [kubectl_manifest.karpenter_node_class_develop_jupyter]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: jupyter-medium
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      template:
        metadata:
          labels:
            jupyter-profile: medium
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: dev-jupyter

          taints:
            - key: jupyter-profile
              value: medium
              effect: NoSchedule

          requirements:
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["on-demand"]

            - key: kubernetes.io/arch
              operator: In
              values: ["amd64"]

            - key: kubernetes.io/os
              operator: In
              values: ["linux"]

            - key: karpenter.k8s.aws/instance-family
              operator: In
              values: ["r7i", "r6i", "r5"]

            - key: karpenter.k8s.aws/instance-size
              operator: In
              values: ["xlarge"]

      limits:
        cpu: ${var.default_nodepool_node_limit}

      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 5m
        expireAfter: 168h

        budgets:
          - nodes: "100%"
  YAML
}

# --- Large Instances NodePool ---
resource "kubectl_manifest" "karpenter_node_pool_jupyter_large" {
  depends_on = [kubectl_manifest.karpenter_node_class_develop_jupyter]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: jupyter-large
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      template:
        metadata:
          labels:
            jupyter-profile: large
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: dev-jupyter

          taints:
            - key: jupyter-profile
              value: large
              effect: NoSchedule

          requirements:
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["on-demand"]

            - key: kubernetes.io/arch
              operator: In
              values: ["amd64"]

            - key: kubernetes.io/os
              operator: In
              values: ["linux"]

            - key: karpenter.k8s.aws/instance-family
              operator: In
              values: ["r7i", "r6i", "r5"]

            - key: karpenter.k8s.aws/instance-size
              operator: In
              values: ["2xlarge"]

      limits:
        cpu: ${var.default_nodepool_node_limit}

      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 5m
        expireAfter: 168h

        budgets:
          - nodes: "100%"
  YAML
}

# --- Very Large Instances NodePool ---
resource "kubectl_manifest" "karpenter_node_pool_jupyter_very_large" {
  depends_on = [kubectl_manifest.karpenter_node_class_develop_jupyter]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: jupyter-very-large
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      template:
        metadata:
          labels:
            jupyter-profile: very-large
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: dev-jupyter
          taints:
            - key: jupyter-profile
              value: very-large
              effect: NoSchedule
          requirements:
            - key: karpenter.k8s.aws/instance-family
              operator: In
              values: ["r7i", "r6i", "r5"]
            - key: karpenter.k8s.aws/instance-size
              operator: In
              values: ["8xlarge"]  # ~256GB RAM
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["on-demand"]
            - key: kubernetes.io/arch
              operator: In
              values: ["amd64"]
            - key: kubernetes.io/os
              operator: In
              values: ["linux"]

      limits:
        cpu: ${var.default_nodepool_node_limit}

      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 5m
        expireAfter: 168h
        budgets:
          - nodes: "100%"
  YAML
}

# --- Ultra Large Instances NodePool (r7i.8xlarge) ---
resource "kubectl_manifest" "karpenter_node_pool_jupyter_ultra" {
  depends_on = [kubectl_manifest.karpenter_node_class_develop_jupyter]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: jupyter-ultra
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      template:
        metadata:
          labels:
            jupyter-profile: ultra
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: dev-jupyter
          taints:
            - key: jupyter-profile
              value: ultra
              effect: NoSchedule
          requirements:
            - key: karpenter.k8s.aws/instance-family
              operator: In
              values: ["r7i", "r6i", "r5"]
            - key: karpenter.k8s.aws/instance-size
              operator: In
              values: ["8xlarge"]
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["on-demand"]
            - key: kubernetes.io/arch
              operator: In
              values: ["amd64"]
            - key: kubernetes.io/os
              operator: In
              values: ["linux"]

      limits:
        cpu: ${var.default_nodepool_node_limit}

      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 5m
        expireAfter: 168h
        budgets:
          - nodes: "100%"
  YAML
}

######################################################
# --- Data Production Nodeclasses ------
######################################################
resource "kubectl_manifest" "karpenter_node_class_data_production" {
  depends_on = [
    helm_release.karpenter,
    time_sleep.wait_for_karpenter
  ]

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: data-production
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      amiFamily: AL2023
      role: ${module.karpenter.node_iam_role_name}
      amiSelectorTerms:
        - alias: ${var.default_nodepool_ami_alias}
      blockDeviceMappings:
        - deviceName: /dev/xvda
          ebs:
            volumeSize: 30Gi
            volumeType: gp3
            deleteOnTermination: true
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.cluster}
            SubnetType: "Public"
      associatePublicIPAddress: true
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${local.cluster}
      tags:
        NodeGroup: "Data-Production"
  YAML
}


# --- R Series with 16x Large NodePool ---
resource "kubectl_manifest" "karpenter_node_pool_data_production_r_16xlarge" {
  depends_on = [kubectl_manifest.karpenter_node_class_data_production]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: data-production-r16xlarge
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      template:
        metadata:
          labels:
            data-production: r16xlarge
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: data-production

          taints:
            - key: data-production
              value: r16xlarge
              effect: NoSchedule

          requirements:
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["spot"]

            - key: kubernetes.io/arch
              operator: In
              values: ["amd64"]

            - key: kubernetes.io/os
              operator: In
              values: ["linux"]

            - key: karpenter.k8s.aws/instance-family
              operator: In
              values: ["r7i", "r6i", "r5"]

            - key: karpenter.k8s.aws/instance-size
              operator: In
              values: ["16xlarge"]

      limits:
        cpu: ${var.data_production_cpu_limit}

      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 5m
        expireAfter: 168h

        budgets:
          - nodes: "100%"
  YAML
}


# --- R Series with 12x Large NodePool ---
resource "kubectl_manifest" "karpenter_node_pool_data_production_r_12xlarge" {
  depends_on = [kubectl_manifest.karpenter_node_class_data_production]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: data-production-r12xlarge
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      template:
        metadata:
          labels:
            data-production: r12xlarge
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: data-production

          taints:
            - key: data-production
              value: r12xlarge
              effect: NoSchedule

          requirements:
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["spot"]

            - key: kubernetes.io/arch
              operator: In
              values: ["amd64"]

            - key: kubernetes.io/os
              operator: In
              values: ["linux"]

            - key: karpenter.k8s.aws/instance-family
              operator: In
              values: ["r7i", "r6i", "r5"]

            - key: karpenter.k8s.aws/instance-size
              operator: In
              values: ["12xlarge"]

      limits:
        cpu: ${var.data_production_cpu_limit}

      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 5m
        expireAfter: 168h

        budgets:
          - nodes: "100%"
  YAML
}

# --- R Series with 8x Large NodePool ---
resource "kubectl_manifest" "karpenter_node_pool_data_production_r_8xlarge" {
  depends_on = [kubectl_manifest.karpenter_node_class_data_production]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: data-production-r8xlarge
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      template:
        metadata:
          labels:
            data-production: r8xlarge
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: data-production

          taints:
            - key: data-production
              value: r8xlarge
              effect: NoSchedule

          requirements:
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["spot"]

            - key: kubernetes.io/arch
              operator: In
              values: ["amd64"]

            - key: kubernetes.io/os
              operator: In
              values: ["linux"]

            - key: karpenter.k8s.aws/instance-family
              operator: In
              values: ["r7i", "r6i", "r5"]

            - key: karpenter.k8s.aws/instance-size
              operator: In
              values: ["8xlarge"]

      limits:
        cpu: ${var.data_production_cpu_limit}

      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 5m
        expireAfter: 168h

        budgets:
          - nodes: "100%"
  YAML
}

# --- R Series with 4x Large NodePool ---
resource "kubectl_manifest" "karpenter_node_pool_data_production_r_4xlarge" {
  depends_on = [kubectl_manifest.karpenter_node_class_data_production]

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: data-production-r4xlarge
      labels:
        app.kubernetes.io/managed-by: terraform
    spec:
      template:
        metadata:
          labels:
            data-production: r4xlarge
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: data-production

          taints:
            - key: data-production
              value: r4xlarge
              effect: NoSchedule

          requirements:
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["spot"]

            - key: kubernetes.io/arch
              operator: In
              values: ["amd64"]

            - key: kubernetes.io/os
              operator: In
              values: ["linux"]

            - key: karpenter.k8s.aws/instance-family
              operator: In
              values: ["r7i", "r6i", "r5"]

            - key: karpenter.k8s.aws/instance-size
              operator: In
              values: ["4xlarge"]

      limits:
        cpu: ${var.data_production_cpu_limit}

      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 5m
        expireAfter: 168h

        budgets:
          - nodes: "100%"
  YAML
}
