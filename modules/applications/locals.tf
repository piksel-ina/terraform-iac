locals {
  prefix = "${lower(var.project)}-${lower(var.environment)}"
  tags   = var.default_tags

  # The public domain must be the first entry in the list.
  subdomain = var.subdomains[0]

  # Buckets granted read access to data-reader roles (ODC, STAC, JupyterHub, Argo).
  read_buckets = concat(var.read_external_buckets, var.internal_buckets)

  # Namespaces
  monitoring_namespace = "monitoring"
  jhub_namespace       = "jupyterhub"
  argo_namespace       = "argo-workflows"
  odc_namespace        = "open-datacube"
  stac_namespace       = "odc-stac"
  terria_namespace     = "terria"
  tileserver_namespace = "tileserver"

  # Service accounts
  sa_grafana    = "grafana"
  sa_hub_read   = "user-read"
  sa_argo_exec  = "argo-workflows-executor"
  sa_argo_serve = "argo-workflows-server"
  sa_odc_read   = "odc-data-reader"
  sa_stac_read  = "stac-data-reader"
  sa_terria     = "terria-sa"

  # Subdomains per app (public hosted UI is shared: var.cognito_auth_domain)
  jhub_subdomain    = "sandbox.${local.subdomain}"
  grafana_subdomain = "grafana.${local.subdomain}"

  # Cognito OAuth client credentials stored in Secrets Manager as "clientid:clientsecret".
  cognito_secret_argo       = "argo-oauth-${lower(var.environment)}"
  cognito_secret_jupyterhub = "jupyterhub-oauth-${lower(var.environment)}"
  cognito_secret_grafana    = "grafana-oauth-${lower(var.environment)}"

  # Master DB credentials secret (created by the rds module).
  db_master_secret = "database-password"
  db_name          = lower(var.project)
  db_username      = replace("${lower(var.project)}_${lower(var.environment)}", "/[^a-zA-Z0-9_]/", "")
}

data "aws_secretsmanager_secret_version" "db_master" {
  secret_id = local.db_master_secret
}
