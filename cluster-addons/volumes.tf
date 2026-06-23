# --- EFS PersistentVolume for Argo (static provisioning via access point) ---

resource "kubectl_manifest" "pv_efs_public_data_argo" {
  depends_on = [helm_release.aws_efs_csi_driver]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "PersistentVolume"
    metadata = {
      name = "pv-efs-public-data-argo"
    }
    spec = {
      capacity = {
        storage = "1Gi"
      }
      volumeMode                    = "Filesystem"
      accessModes                   = ["ReadWriteMany"]
      persistentVolumeReclaimPolicy = "Retain"
      storageClassName              = ""
      csi = {
        driver       = "efs.csi.aws.com"
        volumeHandle = "${var.efs_filesystem_id}::fsap-07899f99d06ff46e3"
      }
    }
  })
}

# --- PVCs in jupyterhub namespace ---

resource "kubectl_manifest" "pvc_efs_public_data_jupyterhub" {
  depends_on = [
    kubectl_manifest.efs_public_readonly_storageclass,
    helm_release.aws_efs_csi_driver,
  ]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "PersistentVolumeClaim"
    metadata = {
      name      = "efs-public-data"
      namespace = "jupyterhub"
    }
    spec = {
      accessModes      = ["ReadWriteMany"]
      storageClassName = "efs-public-readonly"
      resources = {
        requests = {
          storage = "1Gi"
        }
      }
    }
  })
}

resource "kubectl_manifest" "pv_efs_coastlines_data_jupyterhub" {
  depends_on = [helm_release.aws_efs_csi_driver]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "PersistentVolume"
    metadata = {
      name = "pv-efs-coastlines-data-jupyterhub"
    }
    spec = {
      capacity = {
        storage = "1Gi"
      }
      volumeMode                    = "Filesystem"
      accessModes                   = ["ReadWriteMany"]
      persistentVolumeReclaimPolicy = "Retain"
      storageClassName              = ""
      csi = {
        driver       = "efs.csi.aws.com"
        volumeHandle = "${var.efs_filesystem_id}::${var.efs_coastlines_access_point_id}"
      }
    }
  })
}

resource "kubectl_manifest" "pvc_efs_coastline_data_jupyterhub" {
  depends_on = [
    kubectl_manifest.pv_efs_coastlines_data_jupyterhub,
    helm_release.aws_efs_csi_driver,
  ]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "PersistentVolumeClaim"
    metadata = {
      name      = "efs-coastline-data"
      namespace = "jupyterhub"
    }
    spec = {
      accessModes      = ["ReadWriteMany"]
      storageClassName = ""
      volumeName       = "pv-efs-coastlines-data-jupyterhub"
      resources = {
        requests = {
          storage = "1Gi"
        }
      }
    }
  })
}

resource "kubectl_manifest" "pvc_efs_all_data_rw_jupyterhub" {
  depends_on = [
    kubectl_manifest.efs_full_access_storageclass,
    helm_release.aws_efs_csi_driver,
  ]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "PersistentVolumeClaim"
    metadata = {
      name      = "efs-all-data-rw"
      namespace = "jupyterhub"
    }
    spec = {
      accessModes      = ["ReadWriteMany"]
      storageClassName = "efs-full-access"
      resources = {
        requests = {
          storage = "1Gi"
        }
      }
    }
  })
}

# --- PVC in argo-workflows namespace (bound to static PV) ---

resource "kubectl_manifest" "pvc_efs_public_data_argo" {
  depends_on = [
    kubectl_manifest.pv_efs_public_data_argo,
    helm_release.aws_efs_csi_driver,
  ]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "PersistentVolumeClaim"
    metadata = {
      name      = "efs-public-data"
      namespace = "argo-workflows"
    }
    spec = {
      accessModes      = ["ReadWriteMany"]
      storageClassName = ""
      volumeName       = "pv-efs-public-data-argo"
      resources = {
        requests = {
          storage = "1Gi"
        }
      }
    }
  })
}

# --- EFS PersistentVolume for shared coastlines mount ---

resource "kubectl_manifest" "pv_efs_coastlines_data" {
  depends_on = [helm_release.aws_efs_csi_driver]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "PersistentVolume"
    metadata = {
      name = "pv-efs-coastlines-data"
    }
    spec = {
      capacity = {
        storage = "1Gi"
      }
      volumeMode                    = "Filesystem"
      accessModes                   = ["ReadWriteMany"]
      persistentVolumeReclaimPolicy = "Retain"
      storageClassName              = ""
      csi = {
        driver       = "efs.csi.aws.com"
        volumeHandle = "${var.efs_filesystem_id}::${var.efs_coastlines_access_point_id}"
      }
    }
  })
}

resource "kubectl_manifest" "pvc_efs_coastlines_data_argo" {
  depends_on = [
    kubectl_manifest.pv_efs_coastlines_data,
    helm_release.aws_efs_csi_driver,
  ]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "PersistentVolumeClaim"
    metadata = {
      name      = "efs-coastlines-data"
      namespace = "argo-workflows"
    }
    spec = {
      accessModes      = ["ReadWriteMany"]
      storageClassName = ""
      volumeName       = "pv-efs-coastlines-data"
      resources = {
        requests = {
          storage = "1Gi"
        }
      }
    }
  })
}
