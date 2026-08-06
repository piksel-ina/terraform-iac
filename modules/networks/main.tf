data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  prefix = "${lower(var.project)}-${lower(var.environment)}"
  azs    = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # /16 split into two /17 zones (public 0-127, private 128-255), each holding 4× /19 slots.
  public_subnets  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 3, i)]
  private_subnets = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 3, i + 4)]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name                  = "${local.prefix}-vpc"
  cidr                  = var.vpc_cidr
  secondary_cidr_blocks = var.secondary_cidr_blocks
  azs                   = local.azs

  public_subnets       = local.public_subnets
  private_subnets      = local.private_subnets
  public_subnet_names  = [for az in local.azs : "${local.prefix}-public-${trimprefix(az, "${var.aws_region}-")}"]
  private_subnet_names = [for az in local.azs : "${local.prefix}-private-${trimprefix(az, "${var.aws_region}-")}"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = var.nat_strategy == "single"
  one_nat_gateway_per_az = var.nat_strategy == "per_az"

  enable_flow_log                                 = var.flow_logs_enabled
  create_flow_log_cloudwatch_log_group            = var.flow_logs_enabled
  flow_log_cloudwatch_log_group_name_prefix       = "${local.prefix}-flow-log"
  flow_log_cloudwatch_log_group_retention_in_days = var.flow_logs_retention_days
  create_flow_log_cloudwatch_iam_role             = var.flow_logs_enabled

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.prefix}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.prefix}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.prefix}-default" }

  public_subnet_tags = {
    "SubnetType"             = "Public"
    "kubernetes.io/role/elb" = 1
    "karpenter.sh/discovery" = var.cluster_name
  }

  private_subnet_tags = {
    "SubnetType"                                = "Private"
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${var.cluster_name}" = 1
    "karpenter.sh/discovery"                    = var.cluster_name
  }

  tags = var.default_tags
}
