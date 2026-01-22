output "webapp_client_id" {
  value = azuread_application.webapp.client_id
  description = "The client ID of the Azure AD Application"
}

output "webapp_client_secret" {
  value = azuread_application_password.webapp_1.value
  description = "The client secret of the Azure AD Application"
  sensitive = true
}

output "webapp_managed_identity_id" {
    value = azurerm_user_assigned_identity.webapp.client_id
    description = "The ID of the User Assigned Identity"
}

