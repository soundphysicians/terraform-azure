output "workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = var.workspace_name
}

output "workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = length(azurerm_log_analytics_workspace.this) > 0 ? azurerm_log_analytics_workspace.this[0].id : data.azurerm_log_analytics_workspace.this[0].id
}