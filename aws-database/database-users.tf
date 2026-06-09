# --- Argo Workflows ---

resource "random_password" "argo" {
  length           = 32
  special          = true
  override_special = "@#$&*+-="
}

resource "aws_secretsmanager_secret" "argo_password" {
  #checkov:skip=CKV_AWS_149:AWS-managed encryption sufficient. Custom KMS CMK to be implemented when further compliance requires it.
  #checkov:skip=CKV2_AWS_57:Terraform-managed password. Rotation via time_rotating to be implemented when CI/CD pipeline is in place.
  name        = "argo-workflows-password"
  description = "Password for Argo Workflow server"

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "argo_password" {
  secret_id     = aws_secretsmanager_secret.argo_password.id
  secret_string = random_password.argo.result
}

# --- Grafana ---

resource "random_password" "grafana" {
  length           = 32
  special          = true
  override_special = "@#$&*+-="
}

resource "aws_secretsmanager_secret" "grafana_password" {
  #checkov:skip=CKV_AWS_149:AWS-managed encryption sufficient. Custom KMS CMK to be implemented when further compliance requires it.
  #checkov:skip=CKV2_AWS_57:Terraform-managed password. Rotation via time_rotating to be implemented when CI/CD pipeline is in place.
  name        = "grafana-db-password"
  description = "Password for Grafana database connection"

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "grafana_password" {
  secret_id     = aws_secretsmanager_secret.grafana_password.id
  secret_string = random_password.grafana.result
}

# --- JupyterHub ---

resource "random_password" "jupyterhub" {
  length           = 32
  special          = false
  override_special = "@#$&*+-="
}

resource "aws_secretsmanager_secret" "jupyterhub_password" {
  #checkov:skip=CKV_AWS_149:AWS-managed encryption sufficient. Custom KMS CMK to be implemented when further compliance requires it.
  #checkov:skip=CKV2_AWS_57:Terraform-managed password. Rotation via time_rotating to be implemented when CI/CD pipeline is in place.
  name = "jupyterhub-password"

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "jupyterhub_password" {
  secret_id     = aws_secretsmanager_secret.jupyterhub_password.id
  secret_string = random_password.jupyterhub.result
}

# --- ODC Write ---

resource "random_password" "odc_write" {
  length           = 32
  special          = true
  override_special = "@#$&*+-="
}

resource "aws_secretsmanager_secret" "odc_write_password" {
  #checkov:skip=CKV_AWS_149:AWS-managed encryption sufficient. Custom KMS CMK to be implemented when further compliance requires it.
  #checkov:skip=CKV2_AWS_57:Terraform-managed password. Rotation via time_rotating to be implemented when CI/CD pipeline is in place.
  name        = "odc-password"
  description = "Password for ODC database connection - Write"

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "odc_write_password" {
  secret_id     = aws_secretsmanager_secret.odc_write_password.id
  secret_string = random_password.odc_write.result
}

# --- ODC Read ---

resource "random_password" "odc_read" {
  length           = 32
  special          = true
  override_special = "@#$&*+-="
}

resource "aws_secretsmanager_secret" "odc_read_password" {
  #checkov:skip=CKV_AWS_149:AWS-managed encryption sufficient. Custom KMS CMK to be implemented when further compliance requires it.
  #checkov:skip=CKV2_AWS_57:Terraform-managed password. Rotation via time_rotating to be implemented when CI/CD pipeline is in place.
  name        = "odc-read-password"
  description = "Password for ODC database connection - Read"

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "odc_read_password" {
  secret_id     = aws_secretsmanager_secret.odc_read_password.id
  secret_string = random_password.odc_read.result
}

# --- STAC Write ---

resource "random_password" "stac_write" {
  length           = 32
  special          = true
  override_special = "@#$&*+-="
}

resource "aws_secretsmanager_secret" "stac_write_password" {
  #checkov:skip=CKV_AWS_149:AWS-managed encryption sufficient. Custom KMS CMK to be implemented when further compliance requires it.
  #checkov:skip=CKV2_AWS_57:Terraform-managed password. Rotation via time_rotating to be implemented when CI/CD pipeline is in place.
  name        = "stac-write-password"
  description = "Password for STAC database connection - Write"

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "stac_write_password" {
  secret_id     = aws_secretsmanager_secret.stac_write_password.id
  secret_string = random_password.stac_write.result
}

# --- STAC Read ---

resource "random_password" "stac_read" {
  length           = 32
  special          = true
  override_special = "@#$&*+-="
}

resource "aws_secretsmanager_secret" "stacread_password" {
  #checkov:skip=CKV_AWS_149:AWS-managed encryption sufficient. Custom KMS CMK to be implemented when further compliance requires it.
  #checkov:skip=CKV2_AWS_57:Terraform-managed password. Rotation via time_rotating to be implemented when CI/CD pipeline is in place.
  name        = "stac-read-password"
  description = "Password for STAC database connection - Read"

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "stacread_password" {
  secret_id     = aws_secretsmanager_secret.stacread_password.id
  secret_string = random_password.stac_read.result
}

# --- User configuration map ---

locals {
  app_users = {
    argo = {
      password        = random_password.argo.result
      target_database = "argo"
      permissions     = "full"
    }
    jupyterhub = {
      password        = random_password.jupyterhub.result
      target_database = "jupyterhub"
      permissions     = "full"
    }
    grafana = {
      password        = random_password.grafana.result
      target_database = "grafana"
      permissions     = "grafana"
    }
    stac = {
      password        = random_password.stac_write.result
      target_database = "stac"
      permissions     = "full"
    }
    stacread = {
      password        = random_password.stac_read.result
      target_database = "stac"
      permissions     = "readonly"
    }
    odc = {
      password        = random_password.odc_write.result
      target_database = "odc"
      permissions     = "full"
    }
    odcread = {
      password        = random_password.odc_read.result
      target_database = "odc"
      permissions     = "readonly"
    }
  }

  additional_databases = ["argo", "jupyterhub", "grafana", "stac", "odc"]
}

# --- Extensions ---

resource "postgresql_extension" "postgis" {
  name     = "postgis"
  database = "odc"

  depends_on = [postgresql_database.app_databases]
}

resource "postgresql_extension" "postgis_stac" {
  name     = "postgis"
  database = "stac"

  depends_on = [postgresql_database.app_databases]
}

# --- Databases ---

resource "postgresql_database" "app_databases" {
  for_each = toset(local.additional_databases)

  name     = each.value
  owner    = local.db_username
  encoding = "UTF8"

  depends_on = [module.db]
}

# --- Roles ---

resource "postgresql_role" "app_users" {
  for_each = local.app_users

  name     = each.key
  login    = true
  password = each.value.password

  depends_on = [module.db]
}

# --- ODC role grants ---

resource "postgresql_grant_role" "odc_manage" {
  role       = "odc"
  grant_role = "odc_manage"

  depends_on = [postgresql_role.app_users]
}

# --- Connect grants ---

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

# --- Full permissions (SELECT, INSERT, UPDATE, DELETE) ---

resource "postgresql_grant" "full_table_permissions" {
  for_each = {
    for k, v in local.app_users : k => v if v.permissions == "full"
  }

  database    = each.value.target_database
  role        = each.key
  object_type = "table"
  schema      = "public"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]

  depends_on = [postgresql_grant.schema_usage]
}

resource "postgresql_grant" "full_sequence_permissions" {
  for_each = {
    for k, v in local.app_users : k => v if v.permissions == "full"
  }

  database    = each.value.target_database
  role        = each.key
  object_type = "sequence"
  schema      = "public"
  privileges  = ["USAGE", "SELECT"]

  depends_on = [postgresql_grant.schema_usage]
}


# --- Read-only permissions ---

resource "postgresql_grant" "readonly_table_permissions" {
  for_each = {
    for k, v in local.app_users : k => v if v.permissions == "readonly"
  }

  database    = each.value.target_database
  role        = each.key
  object_type = "table"
  schema      = "public"
  privileges  = ["SELECT"]

  depends_on = [postgresql_grant.schema_usage, postgresql_grant.full_table_permissions]
}

resource "postgresql_grant" "readonly_sequence_permissions" {
  for_each = {
    for k, v in local.app_users : k => v if v.permissions == "readonly"
  }

  database    = each.value.target_database
  role        = each.key
  object_type = "sequence"
  schema      = "public"
  privileges  = ["USAGE", "SELECT"]

  depends_on = [postgresql_grant.schema_usage]
}

# --- Grafana permissions (read-only) ---

resource "postgresql_grant" "grafana_table_permissions" {
  for_each = {
    for k, v in local.app_users : k => v if v.permissions == "grafana"
  }

  database    = each.value.target_database
  role        = each.key
  object_type = "table"
  schema      = "public"
  privileges  = ["SELECT"]

  depends_on = [postgresql_grant.schema_usage]
}

resource "postgresql_grant" "grafana_sequence_permissions" {
  for_each = {
    for k, v in local.app_users : k => v if v.permissions == "grafana"
  }

  database    = each.value.target_database
  role        = each.key
  object_type = "sequence"
  schema      = "public"
  privileges  = ["USAGE", "SELECT"]

  depends_on = [postgresql_grant.schema_usage]
}

# --- Default privileges for future objects (full users) ---

resource "postgresql_default_privileges" "full_table_defaults" {
  for_each = {
    for k, v in local.app_users : k => v if v.permissions == "full"
  }

  database    = each.value.target_database
  role        = local.db_username
  schema      = "public"
  owner       = each.key
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_default_privileges" "full_sequence_defaults" {
  for_each = {
    for k, v in local.app_users : k => v if v.permissions == "full"
  }

  database    = each.value.target_database
  role        = local.db_username
  schema      = "public"
  owner       = each.key
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT"]
}

# --- Default privileges for future objects (readonly users) ---

resource "postgresql_default_privileges" "readonly_table_defaults" {
  for_each = {
    for k, v in local.app_users : k => v if v.permissions == "readonly"
  }

  database    = each.value.target_database
  role        = local.db_username
  schema      = "public"
  owner       = each.key
  object_type = "table"
  privileges  = ["SELECT"]
}

resource "postgresql_default_privileges" "readonly_sequence_defaults" {
  for_each = {
    for k, v in local.app_users : k => v if v.permissions == "readonly"
  }

  database    = each.value.target_database
  role        = local.db_username
  schema      = "public"
  owner       = each.key
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT"]
}

# --- Default privileges for future objects (grafana users) ---

resource "postgresql_default_privileges" "grafana_table_defaults" {
  for_each = {
    for k, v in local.app_users : k => v if v.permissions == "grafana"
  }

  database    = each.value.target_database
  role        = local.db_username
  schema      = "public"
  owner       = each.key
  object_type = "table"
  privileges  = ["SELECT"]
}

resource "postgresql_default_privileges" "grafana_sequence_defaults" {
  for_each = {
    for k, v in local.app_users : k => v if v.permissions == "grafana"
  }

  database    = each.value.target_database
  role        = local.db_username
  schema      = "public"
  owner       = each.key
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT"]
}
