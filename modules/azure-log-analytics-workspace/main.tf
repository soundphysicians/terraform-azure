locals {
  tags = {
    project     = var.project
    environment = var.environment
  }
}

resource "azurerm_log_analytics_workspace" "this" {
  count               = var.create_in_environment ? 1 : 0
  name                = var.workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  retention_in_days   = var.retention_in_days

  tags = local.tags
}

data "azurerm_log_analytics_workspace" "this" {
  count               = var.create_in_environment ? 0 : 1
  name                = var.workspace_name
  resource_group_name = var.resource_group_name
}