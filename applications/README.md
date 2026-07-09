<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.40.0 |
| <a name="provider_aws.cross_account"></a> [aws.cross\_account](#provider\_aws.cross\_account) | 6.40.0 |
| <a name="provider_aws.virginia"></a> [aws.virginia](#provider\_aws.virginia) | 6.40.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.0.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_eks_role_bucket_odc"></a> [iam\_eks\_role\_bucket\_odc](#module\_iam\_eks\_role\_bucket\_odc) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.0 |
| <a name="module_iam_eks_role_hub_reader"></a> [iam\_eks\_role\_hub\_reader](#module\_iam\_eks\_role\_hub\_reader) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.0 |
| <a name="module_iam_eks_role_stac"></a> [iam\_eks\_role\_stac](#module\_iam\_eks\_role\_stac) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.ows_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.ows_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.ows_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_response_headers_policy.ows_cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |
| [aws_cloudwatch_log_group.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_iam_policy.argo_artifact_read_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.argo_public_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.grafana_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.hub_user_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.stac_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.terria_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.argo_workflow_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.grafana](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.odc_cloudfront_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.terria_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.odc_cloudfront_assume_crossaccount](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.argo_workflow_public_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.argo_workflow_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.grafana_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.terria_s3_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_route53_record.ows_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.ows_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.argo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.terria_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.argo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.terria](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_wafv2_web_acl.ows_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_logging_configuration.ows_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |
| [kubernetes_config_map.terria_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_namespace.argo_workflow](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.hub](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.monitoring](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.odc](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.stac](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.terria](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.tileserver](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.argo_db_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.argo_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.argo_server_sso](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.grafana](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.grafana_admin_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.grafana_oauth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.grafana_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.hub_db_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.jupyterhub](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.jupyterhub_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.odc_namespace_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.odc_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.odcread_namespace_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.odcread_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.stac_namespace_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.stac_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.stacread_namespace_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.stacread_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service_account.hub_user_read](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.odc_data_reader](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.stac_data_reader](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.terria](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [random_bytes.grafana_admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/bytes) | resource |
| [random_id.jhub_hub_cookie_secret_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.jhub_proxy_secret_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.dask_gateway_api_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_iam_policy_document.grafana_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.grafana_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_secretsmanager_secret_version.argo_client_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.db_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.grafana_client_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.hub_client_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_argo_password"></a> [argo\_password](#input\_argo\_password) | Password for the Argo database user (managed by aws-database module) | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"ap-southeast-3"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster for tagging subnets | `string` | `"piksel-eks-cluster"` | no |
| <a name="input_db_address"></a> [db\_address](#input\_db\_address) | Database address | `string` | n/a | yes |
| <a name="input_db_namespace"></a> [db\_namespace](#input\_db\_namespace) | Kubernetes namespace for the database | `string` | `"database"` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#input\_eks\_oidc\_provider\_arn) | The OIDC issuer ARN for the EKS cluster | `string` | n/a | yes |
| <a name="input_enable_grafana"></a> [enable\_grafana](#input\_enable\_grafana) | Whether to create Grafana-related resources (secrets, IAM, Helm values). The monitoring namespace is always created regardless. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment | `string` | n/a | yes |
| <a name="input_grafana_password"></a> [grafana\_password](#input\_grafana\_password) | Password for the Grafana database user (managed by aws-database module) | `string` | n/a | yes |
| <a name="input_internal_buckets"></a> [internal\_buckets](#input\_internal\_buckets) | List of internal S3 bucket names | `list(string)` | `[]` | no |
| <a name="input_jupyterhub_password"></a> [jupyterhub\_password](#input\_jupyterhub\_password) | Password for the JupyterHub database user (managed by aws-database module) | `string` | n/a | yes |
| <a name="input_k8s_db_service"></a> [k8s\_db\_service](#input\_k8s\_db\_service) | Kubernetes database service FQDN | `string` | n/a | yes |
| <a name="input_lifecycle_expiration_days"></a> [lifecycle\_expiration\_days](#input\_lifecycle\_expiration\_days) | Number of days before S3 objects expire. Override per environment (e.g. staging=60) | `number` | `365` | no |
| <a name="input_oauth_tenant"></a> [oauth\_tenant](#input\_oauth\_tenant) | The oauth tenant URL | `string` | n/a | yes |
| <a name="input_odc_cloudfront_crossaccount_role_arn"></a> [odc\_cloudfront\_crossaccount\_role\_arn](#input\_odc\_cloudfront\_crossaccount\_role\_arn) | value of the cross-account IAM role in CloudFront account | `string` | n/a | yes |
| <a name="input_odc_read_password"></a> [odc\_read\_password](#input\_odc\_read\_password) | Password for the ODC read user (managed by aws-database module) | `string` | n/a | yes |
| <a name="input_odc_write_password"></a> [odc\_write\_password](#input\_odc\_write\_password) | Password for the ODC write user (managed by aws-database module) | `string` | n/a | yes |
| <a name="input_oidc_issuer_url"></a> [oidc\_issuer\_url](#input\_oidc\_issuer\_url) | The OIDC issuer URL for the EKS cluster | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The name of the project | `string` | n/a | yes |
| <a name="input_public_bucket_arn"></a> [public\_bucket\_arn](#input\_public\_bucket\_arn) | ARN of the public S3 bucket for Argo workflow outputs | `string` | n/a | yes |
| <a name="input_public_hosted_zone_id"></a> [public\_hosted\_zone\_id](#input\_public\_hosted\_zone\_id) | The ID of the public hosted zone | `string` | n/a | yes |
| <a name="input_read_external_buckets"></a> [read\_external\_buckets](#input\_read\_external\_buckets) | List of external S3 bucket names | `list(string)` | `[]` | no |
| <a name="input_stac_read_password"></a> [stac\_read\_password](#input\_stac\_read\_password) | Password for the STAC read user (managed by aws-database module) | `string` | n/a | yes |
| <a name="input_stac_write_password"></a> [stac\_write\_password](#input\_stac\_write\_password) | Password for the STAC write user (managed by aws-database module) | `string` | n/a | yes |
| <a name="input_subdomains"></a> [subdomains](#input\_subdomains) | Subdomains for the EKS cluster | `list(string)` | `[]` | no |
| <a name="input_waf_log_retention_days"></a> [waf\_log\_retention\_days](#input\_waf\_log\_retention\_days) | Number of days to retain WAF logs in CloudWatch | `number` | `365` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argo_artifact_bucket_name"></a> [argo\_artifact\_bucket\_name](#output\_argo\_artifact\_bucket\_name) | The name of the S3 bucket for Argo artifacts. |
| <a name="output_argo_artifact_iam_policy_arn"></a> [argo\_artifact\_iam\_policy\_arn](#output\_argo\_artifact\_iam\_policy\_arn) | The ARN of the IAM policy for S3 read/write access. |
| <a name="output_argo_artifact_iam_role_arn"></a> [argo\_artifact\_iam\_role\_arn](#output\_argo\_artifact\_iam\_role\_arn) | The ARN of the IAM role assumed by the Argo artifact service account (IRSA). |
| <a name="output_argo_artifact_service_account_name"></a> [argo\_artifact\_service\_account\_name](#output\_argo\_artifact\_service\_account\_name) | Kubernetes secret containing Argo artifact user credentials. |
| <a name="output_argo_k8s_secret_name"></a> [argo\_k8s\_secret\_name](#output\_argo\_k8s\_secret\_name) | The name of the Kubernetes secret containing the Auth0 client secret. |
| <a name="output_argo_workflow_namespace"></a> [argo\_workflow\_namespace](#output\_argo\_workflow\_namespace) | The namespace for all Argo resources. |
| <a name="output_grafana_admin_secret_name"></a> [grafana\_admin\_secret\_name](#output\_grafana\_admin\_secret\_name) | The name of the Kubernetes secret storing the Grafana admin credentials. Empty when Grafana is disabled. |
| <a name="output_grafana_cloudwatch_policy_arn"></a> [grafana\_cloudwatch\_policy\_arn](#output\_grafana\_cloudwatch\_policy\_arn) | The IAM policy ARN attached to Grafana for CloudWatch access. Empty when Grafana is disabled. |
| <a name="output_grafana_iam_role_arn"></a> [grafana\_iam\_role\_arn](#output\_grafana\_iam\_role\_arn) | The IAM role ARN used by Grafana for IRSA (CloudWatch access). Empty when Grafana is disabled. |
| <a name="output_grafana_namespace"></a> [grafana\_namespace](#output\_grafana\_namespace) | The Kubernetes namespace where monitoring resources are deployed. |
| <a name="output_grafana_oauth_client_secret_arn"></a> [grafana\_oauth\_client\_secret\_arn](#output\_grafana\_oauth\_client\_secret\_arn) | The ARN of the AWS Secrets Manager secret for the Grafana OAuth client/secret. Empty when Grafana is disabled. |
| <a name="output_grafana_values_secret_name"></a> [grafana\_values\_secret\_name](#output\_grafana\_values\_secret\_name) | The name of the Kubernetes secret containing the Grafana Helm values. Empty when Grafana is disabled. |
| <a name="output_jupyterhub_irsa_arn"></a> [jupyterhub\_irsa\_arn](#output\_jupyterhub\_irsa\_arn) | IAM Role ARN for JupyterHub user-read service account (IRSA) |
| <a name="output_jupyterhub_namespace"></a> [jupyterhub\_namespace](#output\_jupyterhub\_namespace) | The namespace where JupyterHub is deployed |
| <a name="output_jupyterhub_service_account_name"></a> [jupyterhub\_service\_account\_name](#output\_jupyterhub\_service\_account\_name) | Kubernetes service account name for S3 read access |
| <a name="output_jupyterhub_subdomain"></a> [jupyterhub\_subdomain](#output\_jupyterhub\_subdomain) | The public subdomain for JupyterHub |
| <a name="output_odc_data_reader_role_arn"></a> [odc\_data\_reader\_role\_arn](#output\_odc\_data\_reader\_role\_arn) | IAM role ARN for ODC data reader |
| <a name="output_odc_namespace"></a> [odc\_namespace](#output\_odc\_namespace) | Kubernetes namespace for ODC |
| <a name="output_ows_cache_certificate_arn"></a> [ows\_cache\_certificate\_arn](#output\_ows\_cache\_certificate\_arn) | ARN of the ACM certificate for ows cache |
| <a name="output_ows_cache_cloudfront_distribution_id"></a> [ows\_cache\_cloudfront\_distribution\_id](#output\_ows\_cache\_cloudfront\_distribution\_id) | CloudFront distribution ID |
| <a name="output_ows_cache_cloudfront_domain_name"></a> [ows\_cache\_cloudfront\_domain\_name](#output\_ows\_cache\_cloudfront\_domain\_name) | CloudFront distribution domain name for ows cache |
| <a name="output_ows_cache_dns_record"></a> [ows\_cache\_dns\_record](#output\_ows\_cache\_dns\_record) | FQDN of the Route53 record for ows cache |
| <a name="output_stac_namespace"></a> [stac\_namespace](#output\_stac\_namespace) | Kubernetes namespace where STAC is deployed. |
| <a name="output_stacread_k8s_secret_name"></a> [stacread\_k8s\_secret\_name](#output\_stacread\_k8s\_secret\_name) | Kubernetes secret name for STAC read credentials. |
| <a name="output_terria_bucket_arn"></a> [terria\_bucket\_arn](#output\_terria\_bucket\_arn) | ARN of the S3 bucket for TerriaMap |
| <a name="output_terria_bucket_name"></a> [terria\_bucket\_name](#output\_terria\_bucket\_name) | The name of the S3 bucket for Terria. |
| <a name="output_terria_configmap_name"></a> [terria\_configmap\_name](#output\_terria\_configmap\_name) | Name of the ConfigMap containing TerriaMap configuration |
| <a name="output_terria_iam_role_arn"></a> [terria\_iam\_role\_arn](#output\_terria\_iam\_role\_arn) | ARN of the IAM role for TerriaMap service account (IRSA) |
| <a name="output_terria_iam_role_name"></a> [terria\_iam\_role\_name](#output\_terria\_iam\_role\_name) | Name of the IAM role for TerriaMap |
| <a name="output_terria_namespace"></a> [terria\_namespace](#output\_terria\_namespace) | Kubernetes namespace for TerriaMap |
| <a name="output_terria_service_account_name"></a> [terria\_service\_account\_name](#output\_terria\_service\_account\_name) | Name of the Kubernetes service account for TerriaMap |
<!-- END_TF_DOCS -->
