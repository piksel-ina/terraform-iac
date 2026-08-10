locals {
  critical_addons_toleration = {
    key      = "CriticalAddonsOnly"
    operator = "Equal"
    value    = "true"
    effect   = "NoSchedule"
  }

  controller_node_selector = {
    "karpenter.sh/controller" = "true"
  }
}

# --- Namespaces ---

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

# --- cert-manager ---

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_chart_version

  wait            = true
  wait_for_jobs   = true
  timeout         = 300
  cleanup_on_fail = true

  values = [
    yamlencode({
      crds = {
        enabled = true
      }
      nodeSelector = local.controller_node_selector
      tolerations  = [local.critical_addons_toleration]
      webhook = {
        nodeSelector = local.controller_node_selector
        tolerations  = [local.critical_addons_toleration]
      }
      cainjector = {
        nodeSelector = local.controller_node_selector
        tolerations  = [local.critical_addons_toleration]
      }
    }),
  ]
}

# --- ingress-nginx ---

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_chart_version

  wait            = true
  wait_for_jobs   = true
  timeout         = 600
  cleanup_on_fail = true

  values = [
    yamlencode({
      controller = {
        replicaCount = 2
        minAvailable = 1
        resources = {
          requests = { cpu = "250m", memory = "256Mi" }
          limits   = { cpu = "1000m", memory = "1Gi" }
        }
        service = {
          type = "LoadBalancer"
        }
        allowSnippetAnnotations = true
        config = {
          use-forwarded-headers      = "true"
          compute-full-forwarded-for = "true"
          forwarded-for-header       = "X-Forwarded-For"
          annotations-risk-level     = "Critical"
        }
        nodeSelector = local.controller_node_selector
        tolerations  = [local.critical_addons_toleration]
        affinity = {
          podAntiAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [{
              weight = 100
              podAffinityTerm = {
                labelSelector = {
                  matchLabels = {
                    "app.kubernetes.io/name"      = "ingress-nginx"
                    "app.kubernetes.io/component" = "controller"
                  }
                }
                topologyKey = "topology.kubernetes.io/zone"
              }
            }]
          }
        }
      }
      admissionWebhooks = {
        enabled = false
      }
    }),
  ]
}

# --- metrics-server ---

resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  namespace        = "kube-system"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  version          = var.metrics_server_chart_version
  create_namespace = false

  wait            = true
  wait_for_jobs   = true
  timeout         = 300
  cleanup_on_fail = true

  values = [
    yamlencode({
      args = [
        "--cert-dir=/tmp",
        "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
        "--kubelet-use-node-status-port",
        "--metric-resolution=15s",
      ]
      resources = {
        requests = { cpu = "100m", memory = "200Mi" }
        limits   = { cpu = "300m", memory = "400Mi" }
      }
      priorityClassName = "system-cluster-critical"
      nodeSelector      = local.controller_node_selector
      tolerations       = [local.critical_addons_toleration]
    }),
  ]
}
