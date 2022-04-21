output "password" {
  value       = local.password
  sensitive   = true
  description = "The Azure SQL user password."
}
