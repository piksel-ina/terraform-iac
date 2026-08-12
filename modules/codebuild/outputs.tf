output "plan_project_name" {
  description = "CodeBuild project name for terraform plan."
  value       = aws_codebuild_project.this["plan"].name
}

output "plan_project_arn" {
  description = "CodeBuild project ARN for terraform plan."
  value       = aws_codebuild_project.this["plan"].arn
}

output "apply_project_name" {
  description = "CodeBuild project name for terraform apply."
  value       = aws_codebuild_project.this["apply"].name
}

output "apply_project_arn" {
  description = "CodeBuild project ARN for terraform apply."
  value       = aws_codebuild_project.this["apply"].arn
}

output "codebuild_role_arn" {
  description = "IAM role ARN used by the CodeBuild projects."
  value       = aws_iam_role.this.arn
}

output "codebuild_security_group_id" {
  description = "Security group ID attached to the CodeBuild projects."
  value       = aws_security_group.this.id
}

output "plan_log_group_arn" {
  description = "ARN of the CloudWatch log group for the plan project."
  value       = "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/codebuild/${var.project}-tf-plan:*"
}

output "apply_log_group_arn" {
  description = "ARN of the CloudWatch log group for the apply project."
  value       = "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/codebuild/${var.project}-tf-apply:*"
}
