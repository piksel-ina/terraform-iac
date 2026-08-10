variable "csi_chart_version" {
  description = "aws-efs-csi-driver Helm chart version."
  type        = string
  default     = "4.4.1"
}

resource "helm_release" "csi_driver" {
  name             = "aws-efs-csi-driver"
  namespace        = var.csi_service_account.namespace
  repository       = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart            = "aws-efs-csi-driver"
  version          = var.csi_chart_version
  create_namespace = false

  wait            = true
  wait_for_jobs   = true
  timeout         = 300
  cleanup_on_fail = true

  values = [
    yamlencode({
      controller = {
        serviceAccount = {
          create = true
          name   = var.csi_service_account.name
        }
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Equal"
            value    = "true"
            effect   = "NoSchedule"
          },
        ]
      }
      node = {
        serviceAccount = {
          create = true
          name   = "efs-csi-node-sa"
        }
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Equal"
            value    = "true"
            effect   = "NoSchedule"
          },
          { operator = "Exists" },
        ]
      }
    }),
  ]

  depends_on = [aws_eks_pod_identity_association.csi]
}

locals {
  storage_classes = {
    efs-public-readonly = {
      basePath       = "/data/public"
      directoryPerms = "755"
      gidRangeStart  = "1000"
      gidRangeEnd    = "2000"
      extra          = {}
    }
    efs-coastline-rw = {
      basePath       = "/data/coastline"
      directoryPerms = "770"
      gidRangeStart  = "2000"
      gidRangeEnd    = "3000"
      extra = {
        uid = "1000"
        gid = "2000"
      }
    }
    efs-full-access = {
      basePath       = "/data"
      directoryPerms = "770"
      gidRangeStart  = "3000"
      gidRangeEnd    = "4000"
      extra = {
        uid = "1000"
        gid = "3000"
      }
    }
  }
}

resource "kubectl_manifest" "storage_class" {
  for_each = local.storage_classes

  depends_on = [helm_release.csi_driver]

  yaml_body = yamlencode({
    apiVersion  = "storage.k8s.io/v1"
    kind        = "StorageClass"
    metadata    = { name = each.key }
    provisioner = "efs.csi.aws.com"
    parameters = merge(
      {
        provisioningMode = "efs-ap"
        fileSystemId     = aws_efs_file_system.data.id
        directoryPerms   = each.value.directoryPerms
        gidRangeStart    = each.value.gidRangeStart
        gidRangeEnd      = each.value.gidRangeEnd
        basePath         = each.value.basePath
      },
      each.value.extra,
    )
    reclaimPolicy        = "Retain"
    volumeBindingMode    = "Immediate"
    allowVolumeExpansion = true
  })
}
