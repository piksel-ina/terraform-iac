<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | 1.26.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_postgresql"></a> [postgresql](#provider\_postgresql) | 1.26.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_db"></a> [db](#module\_db) | terraform-aws-modules/rds/aws | 6.0.0 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-aws-modules/security-group/aws | 5.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.argo_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.db_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.grafana_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.jupyterhub_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.odc_read_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.odc_write_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.stac_write_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.stacread_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.argo_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.db_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.grafana_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.jupyterhub_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.odc_read_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.odc_write_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.stac_write_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.stacread_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [kubernetes_namespace.db](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.db_password](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.db_endpoint](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [postgresql_database.app_databases](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/database) | resource |
| [postgresql_default_privileges.full_sequence_defaults](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/default_privileges) | resource |
| [postgresql_default_privileges.full_table_defaults](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/default_privileges) | resource |
| [postgresql_default_privileges.grafana_sequence_defaults](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/default_privileges) | resource |
| [postgresql_default_privileges.grafana_table_defaults](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/default_privileges) | resource |
| [postgresql_default_privileges.readonly_sequence_defaults](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/default_privileges) | resource |
| [postgresql_default_privileges.readonly_table_defaults](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/default_privileges) | resource |
| [postgresql_extension.postgis](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/extension) | resource |
| [postgresql_grant.database_connect](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/grant) | resource |
| [postgresql_grant.full_sequence_permissions](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/grant) | resource |
| [postgresql_grant.full_table_permissions](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/grant) | resource |
| [postgresql_grant.grafana_sequence_permissions](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/grant) | resource |
| [postgresql_grant.grafana_table_permissions](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/grant) | resource |
| [postgresql_grant.readonly_sequence_permissions](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/grant) | resource |
| [postgresql_grant.readonly_table_permissions](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/grant) | resource |
| [postgresql_grant.schema_usage](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/grant) | resource |
| [postgresql_grant_role.odc_manage](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/grant_role) | resource |
| [postgresql_role.app_users](https://registry.terraform.io/providers/cyrilgdn/postgresql/1.26.0/docs/resources/role) | resource |
| [random_password.argo](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.db_random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.grafana](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.jupyterhub](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.odc_read](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.odc_write](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.stac_read](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.stac_write](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of days to retain backups | `number` | `7` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster for tagging subnets | `string` | `"piksel-eks-cluster"` | no |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | The allocated storage in gibibytes for the RDS instance | `number` | `20` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | Database instance class (e.g., db.t3.micro, db.t3.small) | `string` | `"db.t3.micro"` | no |
| <a name="input_db_multi_az"></a> [db\_multi\_az](#input\_db\_multi\_az) | Database multi availability zone deployment | `bool` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment | `string` | n/a | yes |
| <a name="input_is_changes_applied_immediately"></a> [is\_changes\_applied\_immediately](#input\_is\_changes\_applied\_immediately) | Apply RDS Changes Immediately instead during maintenance window | `bool` | `true` | no |
| <a name="input_pg_host"></a> [pg\_host](#input\_pg\_host) | Override PostgreSQL host for the terraform provider. Use 'localhost' when tunnelling via port-forward | `string` | `""` | no |
| <a name="input_pg_port"></a> [pg\_port](#input\_pg\_port) | Override PostgreSQL port for the terraform provider. Use the local port when tunnelling via port-forward | `number` | `5432` | no |
| <a name="input_private_subnets_ids"></a> [private\_subnets\_ids](#input\_private\_subnets\_ids) | List of private subnets ID | `list(string)` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The name of the project | `string` | n/a | yes |
| <a name="input_psql_family"></a> [psql\_family](#input\_psql\_family) | Postrgress Database family | `string` | `"postgres16"` | no |
| <a name="input_psql_major_engine_version"></a> [psql\_major\_engine\_version](#input\_psql\_major\_engine\_version) | Postrgress Database engine version | `string` | `"16"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | CIDR block of the deployment vpc | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC to associate with the security group | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_address"></a> [db\_address](#output\_db\_address) | RDS database address (hostname only) |
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | RDS database endpoint |
| <a name="output_db_instance_id"></a> [db\_instance\_id](#output\_db\_instance\_id) | RDS instance identifier |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | Database name |
| <a name="output_db_namespace"></a> [db\_namespace](#output\_db\_namespace) | Database Kubernetes namespace |
| <a name="output_db_port"></a> [db\_port](#output\_db\_port) | RDS database port |
| <a name="output_db_username"></a> [db\_username](#output\_db\_username) | Database username |
| <a name="output_k8s_db_service"></a> [k8s\_db\_service](#output\_k8s\_db\_service) | Kubernetes database service FQDN |
| <a name="output_security_group_arn_database"></a> [security\_group\_arn\_database](#output\_security\_group\_arn\_database) | The ARN of the security group |
| <a name="output_security_group_description_database"></a> [security\_group\_description\_database](#output\_security\_group\_description\_database) | The description of the security group |
| <a name="output_security_group_id_database"></a> [security\_group\_id\_database](#output\_security\_group\_id\_database) | The ID of the security group |
| <a name="output_security_group_name_database"></a> [security\_group\_name\_database](#output\_security\_group\_name\_database) | The name of the security group |
| <a name="output_user_passwords"></a> [user\_passwords](#output\_user\_passwords) | Map of application database user passwords |
<!-- END_TF_DOCS -->
