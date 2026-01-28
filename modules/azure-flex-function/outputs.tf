output "id" {
  value       = azurerm_function_app_flex_consumption.app.id
  description = "The ID of the Function App"
}

output "name" {
  value       = azurerm_function_app_flex_consumption.app.name
  description = "The name of the Function App"
}

output "default_hostname" {
  value       = azurerm_function_app_flex_consumption.app.default_hostname
  description = "The default hostname of the Function App"
}

output "identity_principal_id" {
  value       = azurerm_user_assigned_identity.app.principal_id
  description = "The principal ID of the user assigned identity"
}

output "identity_client_id" {
  value       = azurerm_user_assigned_identity.app.client_id
  description = "The client ID of the user assigned identity"
}

output "identity_id" {
  value       = azurerm_user_assigned_identity.app.id
  description = "The ID of the user assigned identity"
}

output "storage_account_name" {
  value       = module.storage_account.name
  description = "The name of the storage account used by the Function App"
}

output "storage_account_id" {
  value       = module.storage_account.id
  description = "The ID of the storage account used by the Function App"
}

output "service_plan_id" {
  value       = azurerm_service_plan.plan.id
  description = "The ID of the service plan"
}

output "service_plan_name" {
  value       = azurerm_service_plan.plan.name
  description = "The name of the service plan"
}

output "app_registration_client_id" {
  value       = azuread_application.app.client_id
  description = "The client ID of the Azure AD application registration"
}

output "app_registration_object_id" {
  value       = azuread_application.app.object_id
  description = "The object ID of the Azure AD application registration"
}

output "service_principal_object_id" {
  value       = azuread_service_principal.app.object_id
  description = "The object ID of the service principal"
}
