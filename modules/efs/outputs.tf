output "filesystem_id" {
  description = "EFS filesystem ID."
  value       = aws_efs_file_system.data.id
}

output "filesystem_arn" {
  description = "EFS filesystem ARN."
  value       = aws_efs_file_system.data.arn
}

output "security_group_id" {
  description = "Security group ID for EFS mount targets. Grant NFS access to additional clients by referencing this."
  value       = aws_security_group.efs.id
}

output "csi_role_arn" {
  description = "IAM role ARN used by the EFS CSI controller via Pod Identity."
  value       = aws_iam_role.csi.arn
}
