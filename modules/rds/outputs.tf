output "db_endpoint" {
  description = "RDS endpoint (host:port)."
  value       = module.db.db_instance_endpoint
}

output "db_address" {
  description = "RDS hostname."
  value       = split(":", module.db.db_instance_endpoint)[0]
}

output "db_port" {
  description = "RDS port."
  value       = module.db.db_instance_port
}

output "db_name" {
  description = "Master database name."
  value       = local.project
}

output "db_username" {
  description = "Master DB username."
  value       = local.db_username
  sensitive   = true
}

output "db_instance_id" {
  description = "RDS instance identifier."
  value       = module.db.db_instance_identifier
}

output "db_namespace" {
  description = "Kubernetes namespace for the DB ExternalName service and secret."
  value       = kubernetes_namespace.db.metadata[0].name
}

output "k8s_db_service" {
  description = "Cluster-local DNS name that resolves to the RDS endpoint."
  value       = "${kubernetes_service.db_endpoint.metadata[0].name}.${kubernetes_service.db_endpoint.metadata[0].namespace}.svc.cluster.local"
}

output "security_group_id" {
  description = "ID of the DB security group."
  value       = module.security_group.id
}

output "user_passwords" {
  description = "Map of app user passwords, keyed by role name."
  value       = { for k, _ in local.app_users : k => random_password.app_users[k].result }
  sensitive   = true
}
