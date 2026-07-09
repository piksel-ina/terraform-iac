## Terraform State Backup

Simple backup script for Terraform state files to S3.

### Usage

**Backup (run after every `terraform apply`):**

```bash
bash backup.sh run
```

**Restore:**

```bash
bash backup.sh get
```

Files will be downloaded to `tf_backedup/` directory.

### Restoring Files

After downloading backup:

1. Review files in `tf_backedup/`
2. Manually move files to Terraform directory
3. **⚠️ Be careful:** Overwriting `terraform.tfstate` with wrong version will cause state desync and mess up infrastructure

### When to Use

- Local backend failure
- Accidental state file deletion
- Need to recover previous state

### Important Notes

- **Solo workflow only** - rethink approach if team grows
- **Always backup after `terraform apply`**
- Versioning is enabled on S3 bucket for safety

### Configuration

Edit `backup.sh` if needed:

- Profile: `staging-piksel`
- Region: `ap-southeast-3`
- Bucket: `terraform-backup-staging-piksel-taufik`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0, < 7.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.19.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | 1.26.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.53.0 |
| <a name="provider_aws.aws"></a> [aws.aws](#provider\_aws.aws) | 6.53.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_applications"></a> [applications](#module\_applications) | ../applications | n/a |
| <a name="module_cluster-addons"></a> [cluster-addons](#module\_cluster-addons) | ../cluster-addons | n/a |
| <a name="module_codebuild"></a> [codebuild](#module\_codebuild) | ../codebuild | n/a |
| <a name="module_database"></a> [database](#module\_database) | ../aws-database | n/a |
| <a name="module_eks-cluster"></a> [eks-cluster](#module\_eks-cluster) | ../aws-eks-cluster | n/a |
| <a name="module_external-dns"></a> [external-dns](#module\_external-dns) | ../external-dns | n/a |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | ../karpenter | n/a |
| <a name="module_networks"></a> [networks](#module\_networks) | ../networks | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | ../aws-s3-bucket | n/a |
| <a name="module_website"></a> [website](#module\_website) | ../aws-s3-static-hosting | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.admin_nightly_stop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.admin_nightly_stop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_instance_profile.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.github_tf_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.github_website_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.admin_autostop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.admin_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.github_tf_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.github_website_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.admin_autostop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.admin_ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.admin_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.admin_ssm_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.github_tf_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.github_website_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.admin_efs_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.codebuild_to_eks_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.admin_ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.admin_ec2_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.admin_ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.admin_eventbridge_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.admin_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [cloudinit_config.admin](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region to deploy resources in | `string` | `"ap-southeast-3"` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | A map of default tags to apply to all AWS resources | `map(string)` | <pre>{<br/>  "Environment": "Staging",<br/>  "ManagedBy": "Terraform",<br/>  "Owner": "Piksel-Devops-Team",<br/>  "Project": "Piksel"<br/>}</pre> | no |
| <a name="input_enable_flow_log"></a> [enable\_flow\_log](#input\_enable\_flow\_log) | Enable VPC Flow Logs for monitoring network traffic | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment of the deployment | `string` | `"Staging"` | no |
| <a name="input_flow_log_retention_days"></a> [flow\_log\_retention\_days](#input\_flow\_log\_retention\_days) | Retention period for VPC Flow Logs in CloudWatch (in days) | `number` | `90` | no |
| <a name="input_one_nat_gateway_per_az"></a> [one\_nat\_gateway\_per\_az](#input\_one\_nat\_gateway\_per\_az) | Enable one NAT Gateway per Availability Zone (higher availability, higher cost) | `bool` | `false` | no |
| <a name="input_pg_host"></a> [pg\_host](#input\_pg\_host) | Override PostgreSQL host for the terraform provider. Use 'localhost' when tunnelling via port-forward | `string` | `""` | no |
| <a name="input_pg_port"></a> [pg\_port](#input\_pg\_port) | Override PostgreSQL port for the terraform provider. Use the local port when tunnelling via port-forward | `number` | `5432` | no |
| <a name="input_project"></a> [project](#input\_project) | The name of the project | `string` | `"Piksel"` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Enable a single NAT Gateway for all private subnets (cheaper, less availability) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The AWS account ID |
| <a name="output_argo_workflow_metadata"></a> [argo\_workflow\_metadata](#output\_argo\_workflow\_metadata) | Output of Argo Workflow configuration and resources |
| <a name="output_cluster_addons_metadata"></a> [cluster\_addons\_metadata](#output\_cluster\_addons\_metadata) | Cluster addon Helm release statuses |
| <a name="output_codebuild_metadata"></a> [codebuild\_metadata](#output\_codebuild\_metadata) | CodeBuild project details for Terraform CI/CD |
| <a name="output_database_metadata"></a> [database\_metadata](#output\_database\_metadata) | Output of RDS database configuration and resources |
| <a name="output_eks_cluster_metadata"></a> [eks\_cluster\_metadata](#output\_eks\_cluster\_metadata) | Output of EKS Cluster |
| <a name="output_external_dns_metadata"></a> [external\_dns\_metadata](#output\_external\_dns\_metadata) | Output of External DNS configuration and resources |
| <a name="output_github_tf_deploy_role_arn"></a> [github\_tf\_deploy\_role\_arn](#output\_github\_tf\_deploy\_role\_arn) | ARN of the IAM role for GitHub Actions Terraform deployment (OIDC) |
| <a name="output_github_website_deploy_role_arn"></a> [github\_website\_deploy\_role\_arn](#output\_github\_website\_deploy\_role\_arn) | ARN of the IAM role for GitHub Actions website deployment (OIDC) |
| <a name="output_grafana_metadata"></a> [grafana\_metadata](#output\_grafana\_metadata) | Output of Grafana configuration and resources. Values are empty strings when Grafana is disabled. |
| <a name="output_jupyterhub_metadata"></a> [jupyterhub\_metadata](#output\_jupyterhub\_metadata) | Output of JupyterHub configuration and resources |
| <a name="output_karpenter_metadata"></a> [karpenter\_metadata](#output\_karpenter\_metadata) | Output of Karpenter configuration and resources |
| <a name="output_network_metadata"></a> [network\_metadata](#output\_network\_metadata) | Grouped network and connectivity metadata |
| <a name="output_odc_metadata"></a> [odc\_metadata](#output\_odc\_metadata) | Output of ODC configuration and resources |
| <a name="output_odc_ows_cache_metadata"></a> [odc\_ows\_cache\_metadata](#output\_odc\_ows\_cache\_metadata) | Output of ODC OWS Cache configuration and resources |
| <a name="output_s3_public_metadata"></a> [s3\_public\_metadata](#output\_s3\_public\_metadata) | Output of S3 bucket |
| <a name="output_stac_metadata"></a> [stac\_metadata](#output\_stac\_metadata) | Output of STAC configuration and resources |
| <a name="output_terria_metadata"></a> [terria\_metadata](#output\_terria\_metadata) | Output of Terria configuration and resources |
| <a name="output_website_metadata"></a> [website\_metadata](#output\_website\_metadata) | Output of S3 static website hosting configuration and resources |
<!-- END_TF_DOCS -->
