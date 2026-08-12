# --- Namespace for the tile server ---
resource "kubernetes_namespace" "tileserver" {
  metadata {
    name = local.tileserver_namespace
    labels = {
      project     = var.project
      environment = var.environment
      name        = local.tileserver_namespace
    }
  }
  lifecycle {
    ignore_changes = [metadata[0].labels]
  }
}
