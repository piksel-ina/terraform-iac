output "iac_state_bucket_name" {
  description = "IaC state bucket name."
  value       = try(aws_s3_bucket.iac_state[0].bucket, null)
}

output "iac_state_bucket_arn" {
  description = "IaC state bucket ARN."
  value       = try(aws_s3_bucket.iac_state[0].arn, null)
}

output "public_data_bucket_name" {
  description = "Public data bucket name."
  value       = try(aws_s3_bucket.public_data[0].bucket, null)
}

output "public_data_bucket_arn" {
  description = "Public data bucket ARN."
  value       = try(aws_s3_bucket.public_data[0].arn, null)
}

output "argo_artifacts_bucket_name" {
  description = "Argo Workflows artifacts bucket name."
  value       = try(aws_s3_bucket.argo_artifacts[0].bucket, null)
}

output "argo_artifacts_bucket_arn" {
  description = "Argo Workflows artifacts bucket ARN."
  value       = try(aws_s3_bucket.argo_artifacts[0].arn, null)
}

output "terria_bucket_name" {
  description = "Terria bucket name."
  value       = try(aws_s3_bucket.terria[0].bucket, null)
}

output "terria_bucket_arn" {
  description = "Terria bucket ARN."
  value       = try(aws_s3_bucket.terria[0].arn, null)
}
