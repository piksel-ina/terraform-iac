output "plan_project_name" {
  description = "CodeBuild project name for terraform plan"
  value       = aws_codebuild_project.plan.name
}

output "plan_project_arn" {
  description = "CodeBuild project ARN for terraform plan"
  value       = aws_codebuild_project.plan.arn
}

output "apply_project_name" {
  description = "CodeBuild project name for terraform apply"
  value       = aws_codebuild_project.apply.name
}

output "apply_project_arn" {
  description = "CodeBuild project ARN for terraform apply"
  value       = aws_codebuild_project.apply.arn
}

output "codebuild_role_arn" {
  description = "IAM role ARN used by CodeBuild"
  value       = aws_iam_role.codebuild.arn
}

output "codebuild_security_group_id" {
  description = "Security group ID attached to the CodeBuild projects"
  value       = aws_security_group.codebuild.id
}

output "plan_log_group_arn" {
  description = "ARN of the CloudWatch log group for the plan project (CodeBuild-managed)"
  value       = "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/codebuild/${var.project}-tf-plan:*"
}

output "apply_log_group_arn" {
  description = "ARN of the CloudWatch log group for the apply project (CodeBuild-managed)"
  value       = "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/codebuild/${var.project}-tf-apply:*"
}
