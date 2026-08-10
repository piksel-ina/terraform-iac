resource "kubectl_manifest" "gp3" {
  depends_on = [module.eks]

  yaml_body = yamlencode({
    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"
    metadata = {
      name = "gp3"
      annotations = {
        "storageclass.kubernetes.io/is-default-class" = "true"
      }
    }
    provisioner = "ebs.csi.aws.com"
    parameters = {
      type      = "gp3"
      fsType    = "ext4"
      encrypted = "true"
    }
    allowVolumeExpansion = true
    volumeBindingMode    = "WaitForFirstConsumer"
    reclaimPolicy        = "Delete"
  })
}
