locals {
  tags         = var.default_tags
  cluster_name = var.cluster_name
  project      = lower(var.project)
  db_username  = replace("${lower(var.project)}_${lower(var.environment)}", "/[^a-zA-Z0-9_]/", "")
}

resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "#$&*+-="
}

resource "aws_secretsmanager_secret" "master" {
  #checkov:skip=CKV_AWS_149:AWS-managed encryption sufficient.
  #checkov:skip=CKV2_AWS_57:Rotation to be added later.
  name        = "database-password"
  description = "Master password for the ${local.cluster_name} application database."

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "master" {
  secret_id     = aws_secretsmanager_secret.master.id
  secret_string = random_password.master.result
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.2.1"

  identifier                     = "${local.cluster_name}-app-db"
  instance_use_identifier_prefix = true

  create_db_option_group    = false
  create_db_parameter_group = false

  engine               = "postgres"
  engine_version       = var.engine_version
  family               = var.family
  major_engine_version = var.major_engine_version
  instance_class       = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = true

  manage_master_user_password = false
  db_name                     = local.project
  username                    = local.db_username
  password_wo                 = aws_secretsmanager_secret_version.master.secret_string
  password_wo_version         = 1
  port                        = 5432

  create_db_subnet_group = true
  subnet_ids             = var.private_subnets_ids
  multi_az               = var.multi_az

  vpc_security_group_ids = [module.security_group.id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = var.backup_retention_period

  deletion_protection = var.deletion_protection
  apply_immediately   = var.apply_immediately

  tags = merge(local.tags, {
    NodeGroup = "database"
  })
}

resource "kubernetes_namespace" "db" {
  metadata {
    name = "database"
  }
}

resource "kubernetes_secret" "master" {
  metadata {
    name      = "db-password"
    namespace = kubernetes_namespace.db.metadata[0].name
  }
  data = {
    db_name    = local.project
    db_address = split(":", module.db.db_instance_endpoint)[0]
    username   = local.db_username
    password   = aws_secretsmanager_secret_version.master.secret_string
  }
}

resource "kubernetes_service" "db_endpoint" {
  metadata {
    name      = "db-endpoint"
    namespace = kubernetes_namespace.db.metadata[0].name
  }
  spec {
    type          = "ExternalName"
    external_name = split(":", module.db.db_instance_endpoint)[0]
    port {
      port        = 5432
      target_port = 5432
    }
  }
  wait_for_load_balancer = false
}
