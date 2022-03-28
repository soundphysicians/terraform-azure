output "identity_name" {
  description = "The name of the identity that the container runs under"
  value       = var.identity
}

output "identity_id" {
  description = "The ID of the identity that the container runs under"
  value       = azurerm_user_assigned_identity.container.client_id
}
