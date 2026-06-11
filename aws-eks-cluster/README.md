## EKS Cluster Configuration

This Terraform configuration sets up an AWS EKS (Elastic Kubernetes Service) cluster using the `terraform-aws-modules/eks/aws` module. It includes specific configurations for core components, compute types, and access management.

## Key Features

- EKS Cluster Creation: Deploys an EKS cluster with a specified version and public endpoint access.
- IAM Roles for Service Accounts (IRSA):
  - Configures dedicated IAM roles for:
    - ebs-csi-controller-sa (in kube-system) with the AmazonEBSCSIDriverPolicy.
    - aws-node (VPC CNI, in kube-system) with the AmazonEKS_CNI_Policy.
  - These roles allow the respective Kubernetes service accounts to securely interact with AWS APIs.
- Managed EKS Add-ons: Installs and configures essential add-ons:
  - CoreDNS: Deployed onto Fargate with specified resource requests/limits and autoscaling enabled (min 4, max 10 replicas).
  - Kube-Proxy: Standard deployment.
  - VPC CNI: Configured to use the dedicated IRSA role created above.
  - AWS EBS CSI Driver: Configured to use the dedicated IRSA role created above. Set to use the most recent version and overwrite conflicts.
- Fargate Profiles: Configures AWS Fargate as the compute type for Pods in the following namespaces:
  - kube-system
  - karpenter
  - flux-system
  - aws-external-dns-helm
- Networking: Uses provided VPC ID and private subnet IDs. Does _not_ create additional cluster or node security groups, relying on Fargate profile security groups.
- Access Management:
  - Enables cluster creator admin permissions.
  - Utilizes EKS Access Entries to grant AmazonEKSClusterAdminPolicy cluster-wide access to a specified Admin Role ARN (var.sso-admin-role-arn).
- Tagging: Applies default tags and a specific `karpenter.sh/discovery` tag for Karpenter integration.

## Architecture Diagram

This diagram illustrates the key components within the `kube-system` namespace of the EKS cluster and their interaction with AWS services, particularly focusing on DNS, storage, networking, and permissions.

&nbsp; <figure>
<img src="../.images/kube-system.png"
         alt="kube-system deployment diagram for piksel project" width="850" height="auto">

<figcaption><i>Figure: kube-system configuration diagram</i></figcaption>

</figure>

### Explanation:

1.  **EKS Cluster:** The overall Kubernetes control plane and worker node environment managed by AWS EKS. All subsequent components reside within or interact with this cluster.
2.  **CoreDNS Deployment:** A Kubernetes Deployment managing the lifecycle of CoreDNS pods, ensuring the desired number of replicas are running for cluster DNS resolution.
3.  **CoreDNS Pods (on Fargate):** Instances of CoreDNS running on AWS Fargate. These pods handle DNS lookups for services and pods within the cluster. Fargate provides serverless compute, removing the need to manage underlying EC2 instances for these pods.
4.  **kube-dns Service:** A Kubernetes Service providing a stable IP address and DNS name for accessing the CoreDNS pods (2, 3). Pods within the cluster use this service endpoint for DNS queries.
5.  **EBS-CSI-controller Deployment:** A Kubernetes Deployment managing the pods responsible for interacting with the AWS EBS API to provision, attach, detach, and manage the lifecycle of Persistent Volumes.
6.  **EBS-CSI-controller Pods (on Fargate):** Instances of the EBS CSI controller running on AWS Fargate. These pods execute the control plane logic for managing EBS volumes on behalf of the cluster.
7.  **ebs-csi-controller Service Account:** A Kubernetes Service Account providing an identity for the EBS CSI controller pods (6). This identity is linked via IRSA (10) to an AWS IAM Role.
8.  **DaemonSets:** Kubernetes DaemonSets ensuring that specific pods run on relevant nodes (or are managed appropriately in a Fargate context).
    - `aws-node`: Pods for the AWS VPC CNI plugin, responsible for pod networking and IP address management within the VPC (14).
    - `kube-proxy`: Pods managing Kubernetes service routing rules (iptables/ipvs) on each node.
    - `ebs-csi-node`: Pods responsible for node-specific EBS operations like mounting volumes (works in conjunction with the controller).
9.  **aws-node Service Account:** A Kubernetes Service Account providing an identity for the `aws-node` pods (part of 8). This identity is linked via IRSA (10) to an AWS IAM Role.
10. **IRSA (IAM Roles for Service Accounts):** The mechanism connecting Kubernetes Service Accounts (7, 9) to AWS IAM Roles. The EKS OIDC provider acts as a trusted identity provider for AWS IAM, allowing it to validate tokens issued to the Service Accounts.
11. **AWS IAM Policies:** Specific IAM policies (EBS CSI Policy, VPC CNI Policy) defining the exact permissions required by the respective components (EBS CSI controller, VPC CNI plugin) to interact with AWS services (EBS, EC2/VPC). These policies are attached to the IAM Roles used by IRSA (10).
12. **Assume Role:** The AWS STS action performed by the pods (6 and pods from 8 associated with 9), using the token from their Service Account (7, 9). This action exchanges the K8s token for temporary AWS credentials associated with the IAM Role (linked via 10), granting the permissions defined in the attached Policies (11).
13. **Elastic Block Storage (EBS):** The AWS service providing persistent block storage volumes. The EBS CSI controller pods (6) interact with this service via the AWS API (using credentials obtained via 12) to manage volumes for the cluster.
14. **VPC (Virtual Private Cloud):** The AWS networking environment where the EKS cluster and its resources reside. The `aws-node` pods (from 8, using identity 9 and permissions via 10, 11, 12) interact with the VPC to manage IP allocation for pods.

## Documentation

For more detailed documentation, please refer to this documents:

- [AWS EKS CLuster Overview](https://github.com/piksel-ina/piksel-document/blob/main/architecture/eks-cluster-design.md)
- [EKS Add-ons](https://github.com/piksel-ina/piksel-document/blob/main/architecture/eks-addons.md)

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ebs_csi_irsa_role"></a> [ebs\_csi\_irsa\_role](#module\_ebs\_csi\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.55.0 |
| <a name="module_efs_csi_irsa_role"></a> [efs\_csi\_irsa\_role](#module\_efs\_csi\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.55.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 21.0 |
| <a name="module_vpc_cni_irsa_role"></a> [vpc\_cni\_irsa\_role](#module\_vpc\_cni\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.55.0 |

## Resources

| Name | Type |
|------|------|
| [aws_efs_backup_policy.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy) | resource |
| [aws_efs_file_system.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_iam_policy.assume_ecr_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_security_group.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster for tagging subnets | `string` | `"piksel-eks-cluster"` | no |
| <a name="input_codebuild_role_arn"></a> [codebuild\_role\_arn](#input\_codebuild\_role\_arn) | ARN of the CodeBuild IAM role for EKS cluster access | `string` | `""` | no |
| <a name="input_coredns-version"></a> [coredns-version](#input\_coredns-version) | The version of CoreDNS for this environment | `string` | n/a | yes |
| <a name="input_cross_account_ecr_role_arn"></a> [cross\_account\_ecr\_role\_arn](#input\_cross\_account\_ecr\_role\_arn) | Cross Account ECR Role ARN | `string` | `"arn:aws:iam::686410905891:role/piksel-eks-ecr-access"` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_ebs-csi-version"></a> [ebs-csi-version](#input\_ebs-csi-version) | The version of EBS CSI driver | `string` | n/a | yes |
| <a name="input_efs_backup_enabled"></a> [efs\_backup\_enabled](#input\_efs\_backup\_enabled) | Enable EFS backup policy | `bool` | `false` | no |
| <a name="input_eks-version"></a> [eks-version](#input\_eks-version) | The version of Kubernetes for this environment | `string` | n/a | yes |
| <a name="input_kube-proxy-version"></a> [kube-proxy-version](#input\_kube-proxy-version) | The version of kube-proxy for this environment | `string` | n/a | yes |
| <a name="input_pod-identity-version"></a> [pod-identity-version](#input\_pod-identity-version) | The version of EKS Pod Identity Agent addon | `string` | n/a | yes |
| <a name="input_private_subnets_ids"></a> [private\_subnets\_ids](#input\_private\_subnets\_ids) | List of private subnets ID | `list(string)` | n/a | yes |
| <a name="input_sso-admin-role-arn"></a> [sso-admin-role-arn](#input\_sso-admin-role-arn) | The ARN of SSO Admin group | `string` | n/a | yes |
| <a name="input_vpc-cni-version"></a> [vpc-cni-version](#input\_vpc-cni-version) | The version of VPC CNI for this environment | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | CIDR block | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID value | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_authentication_token"></a> [authentication\_token](#output\_authentication\_token) | Token to use to authenticate with the cluster |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | EKS Cluster Certificate Authority Data |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | EKS Cluster Endpoint |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | EKS Cluster Name |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | EKS Cluster OIDC Issuer URL |
| <a name="output_cluster_oidc_provider_arn"></a> [cluster\_oidc\_provider\_arn](#output\_cluster\_oidc\_provider\_arn) | EKS Cluster OIDC Provider ARN |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Security group ID attached to the EKS cluster control plane ENIs |
| <a name="output_cluster_tls_certificate_sha1_fingerprint"></a> [cluster\_tls\_certificate\_sha1\_fingerprint](#output\_cluster\_tls\_certificate\_sha1\_fingerprint) | EKS Cluster TLS Certificate SHA1 Fingerprint |
| <a name="output_efs_csi_irsa_role_arn"></a> [efs\_csi\_irsa\_role\_arn](#output\_efs\_csi\_irsa\_role\_arn) | IAM role ARN for EFS CSI driver controller service account |
| <a name="output_efs_filesystem_id"></a> [efs\_filesystem\_id](#output\_efs\_filesystem\_id) | EFS filesystem ID for CSI driver and StorageClasses |
| <a name="output_efs_security_group_id"></a> [efs\_security\_group\_id](#output\_efs\_security\_group\_id) | Security group ID of the EFS mount targets (for granting NFS access to in-VPC clients) |
<!-- END_TF_DOCS -->
