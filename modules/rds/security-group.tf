module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  name        = "${local.cluster_name}-db-sg"
  description = "PostgreSQL access from within the VPC"
  vpc_id      = var.vpc_id

  ingress_rules = {
    postgres = {
      from_port   = 5432
      to_port     = 5432
      ip_protocol = "tcp"
      cidr_ipv4   = var.vpc_cidr_block
      description = "PostgreSQL from VPC"
    }
  }

  tags = var.default_tags
}
