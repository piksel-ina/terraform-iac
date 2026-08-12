# --- Per-user DB credential secrets ---
# PgBouncer (database namespace) and Argo workflows (argo namespace) consume these
# by username. Passwords originate from the rds module's user_passwords output.
locals {
  db_secret_users      = ["argo", "jupyterhub", "grafana", "stacread", "stac", "odcread", "odc"]
  db_secret_namespaces = [kubernetes_namespace.argo_workflow.metadata[0].name, var.db_namespace]

  db_secret_fanout = {
    for pair in setproduct(local.db_secret_users, local.db_secret_namespaces) :
    "${pair[0]}-${pair[1]}" => {
      user      = pair[0]
      namespace = pair[1]
    }
  }
}

resource "kubernetes_secret" "db_user" {
  for_each = local.db_secret_fanout

  metadata {
    name      = each.value.user
    namespace = each.value.namespace
  }
  data = {
    username = each.value.user
    password = var.db_user_passwords[each.value.user]
  }
  type = "Opaque"
}
