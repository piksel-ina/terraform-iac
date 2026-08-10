output "cert_manager_namespace" {
  description = "Namespace where cert-manager is installed."
  value       = kubernetes_namespace.cert_manager.metadata[0].name
}

output "ingress_nginx_namespace" {
  description = "Namespace where ingress-nginx controller is installed."
  value       = kubernetes_namespace.ingress_nginx.metadata[0].name
}

output "external_dns_role_arn" {
  description = "IAM role ARN used by external-dns."
  value       = aws_iam_role.external_dns.arn
}
