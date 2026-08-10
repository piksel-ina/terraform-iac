locals {
  acme_solvers = [{
    http01 = {
      ingress = {
        ingressClassName = "nginx"
      }
    }
  }]
}

resource "kubectl_manifest" "letsencrypt_production" {
  depends_on = [helm_release.cert_manager]

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata   = { name = "letsencrypt-production" }
    spec = {
      acme = {
        email  = var.acme_email
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt-production"
        }
        solvers = local.acme_solvers
      }
    }
  })
}

resource "kubectl_manifest" "letsencrypt_staging" {
  depends_on = [helm_release.cert_manager]

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata   = { name = "letsencrypt-staging" }
    spec = {
      acme = {
        email  = var.acme_email
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt-staging"
        }
        solvers = local.acme_solvers
      }
    }
  })
}
