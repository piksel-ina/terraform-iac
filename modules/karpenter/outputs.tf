output "controller_iam_role_arn" {
  description = "ARN of the Karpenter controller IAM role."
  value       = module.controller.iam_role_arn
}

output "node_iam_role_name" {
  description = "Name of the IAM role attached to Karpenter-provisioned nodes."
  value       = module.controller.node_iam_role_name
}

output "node_iam_role_arn" {
  description = "ARN of the IAM role attached to Karpenter-provisioned nodes."
  value       = module.controller.node_iam_role_arn
}

output "interruption_queue_name" {
  description = "Name of the SQS interruption queue Karpenter consumes."
  value       = module.controller.queue_name
}

output "helm_release_status" {
  description = "Deployment status of the Karpenter Helm release."
  value       = helm_release.karpenter.status
}
