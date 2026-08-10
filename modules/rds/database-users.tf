locals {
  app_users = {
    argo = {
      target_database = "argo"
      permissions     = "full"
    }
    jupyterhub = {
      target_database = "jupyterhub"
      permissions     = "full"
    }
    grafana = {
      target_database = "grafana"
      permissions     = "grafana"
    }
    stac = {
      target_database = "stac"
      permissions     = "full"
    }
    stacread = {
      target_database = "stac"
      permissions     = "readonly"
    }
    odc = {
      target_database = "odc"
      permissions     = "full"
    }
    odcread = {
      target_database = "odc"
      permissions     = "readonly"
    }
  }

  additional_databases = ["argo", "jupyterhub", "grafana", "stac", "odc"]

  secret_names = {
    argo       = "argo-workflows-password"
    grafana    = "grafana-db-password"
    jupyterhub = "jupyterhub-password"
    odc        = "odc-password"
    odcread    = "odc-read-password"
    stac       = "stac-write-password"
    stacread   = "stac-read-password"
  }
}

resource "random_password" "app_users" {
  for_each = local.app_users

  length           = 32
  special          = each.key != "jupyterhub"
  override_special = "@#$&*+-="
}

resource "aws_secretsmanager_secret" "app_users" {
  #checkov:skip=CKV_AWS_149:AWS-managed encryption sufficient.
  #checkov:skip=CKV2_AWS_57:Rotation to be added later.
  for_each = local.app_users

  name        = local.secret_names[each.key]
  description = "Password for the '${each.key}' application database user."

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "app_users" {
  for_each = local.app_users

  secret_id     = aws_secretsmanager_secret.app_users[each.key].id
  secret_string = random_password.app_users[each.key].result
}

resource "postgresql_database" "app_databases" {
  for_each = toset(local.additional_databases)

  name     = each.value
  owner    = local.db_username
  encoding = "UTF8"

  depends_on = [module.db]
}

resource "postgresql_extension" "postgis_odc" {
  name     = "postgis"
  database = "odc"

  depends_on = [postgresql_database.app_databases]
}

resource "postgresql_extension" "postgis_stac" {
  name     = "postgis"
  database = "stac"

  depends_on = [postgresql_database.app_databases]
}

resource "postgresql_role" "app_users" {
  for_each = local.app_users

  name     = each.key
  login    = true
  password = random_password.app_users[each.key].result

  # Role memberships owned by app bootstrap workflows (pgstac-init, odc-schema-init).
  # Without ignore_changes, an apply would revoke live memberships.
  lifecycle {
    ignore_changes = [roles]
  }

  depends_on = [module.db]
}

resource "postgresql_grant_role" "odc_manage" {
  role       = "odc"
  grant_role = "odc_manage"

  depends_on = [postgresql_role.app_users]
}

resource "postgresql_grant" "database_connect" {
  for_each = local.app_users

  database    = each.value.target_database
  role        = each.key
  object_type = "database"
  privileges  = ["CONNECT"]

  depends_on = [postgresql_role.app_users, postgresql_database.app_databases]
}

resource "postgresql_grant" "schema_usage" {
  for_each = local.app_users

  database    = each.value.target_database
  role        = each.key
  object_type = "schema"
  schema      = "public"
  privileges  = each.value.permissions == "full" ? ["USAGE", "CREATE"] : ["USAGE"]

  depends_on = [postgresql_grant.database_connect]
}

resource "postgresql_grant" "full_table_permissions" {
  for_each = { for k, v in local.app_users : k => v if v.permissions == "full" }

  database    = each.value.target_database
  role        = each.key
  object_type = "table"
  schema      = "public"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]

  depends_on = [postgresql_grant.schema_usage]
}

resource "postgresql_grant" "full_sequence_permissions" {
  for_each = { for k, v in local.app_users : k => v if v.permissions == "full" }

  database    = each.value.target_database
  role        = each.key
  object_type = "sequence"
  schema      = "public"
  privileges  = ["USAGE", "SELECT"]

  depends_on = [postgresql_grant.schema_usage]
}

resource "postgresql_grant" "readonly_table_permissions" {
  for_each = { for k, v in local.app_users : k => v if v.permissions == "readonly" }

  database    = each.value.target_database
  role        = each.key
  object_type = "table"
  schema      = "public"
  privileges  = ["SELECT"]

  depends_on = [postgresql_grant.schema_usage, postgresql_grant.full_table_permissions]
}

resource "postgresql_grant" "readonly_sequence_permissions" {
  for_each = { for k, v in local.app_users : k => v if v.permissions == "readonly" }

  database    = each.value.target_database
  role        = each.key
  object_type = "sequence"
  schema      = "public"
  privileges  = ["USAGE", "SELECT"]

  depends_on = [postgresql_grant.schema_usage]
}

resource "postgresql_grant" "grafana_table_permissions" {
  for_each = { for k, v in local.app_users : k => v if v.permissions == "grafana" }

  database    = each.value.target_database
  role        = each.key
  object_type = "table"
  schema      = "public"
  privileges  = ["SELECT"]

  depends_on = [postgresql_grant.schema_usage]
}

resource "postgresql_grant" "grafana_sequence_permissions" {
  for_each = { for k, v in local.app_users : k => v if v.permissions == "grafana" }

  database    = each.value.target_database
  role        = each.key
  object_type = "sequence"
  schema      = "public"
  privileges  = ["USAGE", "SELECT"]

  depends_on = [postgresql_grant.schema_usage]
}

resource "postgresql_default_privileges" "full_table_defaults" {
  for_each = { for k, v in local.app_users : k => v if v.permissions == "full" }

  database    = each.value.target_database
  role        = local.db_username
  schema      = "public"
  owner       = each.key
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_default_privileges" "full_sequence_defaults" {
  for_each = { for k, v in local.app_users : k => v if v.permissions == "full" }

  database    = each.value.target_database
  role        = local.db_username
  schema      = "public"
  owner       = each.key
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT"]
}

resource "postgresql_default_privileges" "readonly_table_defaults" {
  for_each = { for k, v in local.app_users : k => v if v.permissions == "readonly" }

  database    = each.value.target_database
  role        = local.db_username
  schema      = "public"
  owner       = each.key
  object_type = "table"
  privileges  = ["SELECT"]
}

resource "postgresql_default_privileges" "readonly_sequence_defaults" {
  for_each = { for k, v in local.app_users : k => v if v.permissions == "readonly" }

  database    = each.value.target_database
  role        = local.db_username
  schema      = "public"
  owner       = each.key
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT"]
}

resource "postgresql_default_privileges" "grafana_table_defaults" {
  for_each = { for k, v in local.app_users : k => v if v.permissions == "grafana" }

  database    = each.value.target_database
  role        = local.db_username
  schema      = "public"
  owner       = each.key
  object_type = "table"
  privileges  = ["SELECT"]
}

resource "postgresql_default_privileges" "grafana_sequence_defaults" {
  for_each = { for k, v in local.app_users : k => v if v.permissions == "grafana" }

  database    = each.value.target_database
  role        = local.db_username
  schema      = "public"
  owner       = each.key
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT"]
}
