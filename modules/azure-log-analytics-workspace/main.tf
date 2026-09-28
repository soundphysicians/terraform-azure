locals {
  base_tags = {
    project     = var.project
    environment = var.environment
  }

  non_empty_tag_parameters = { for i, v in coalesce(var.tags, {}) : i => v if v != null && v != "" }
  caller_tag_keys          = toset([for key in keys(local.non_empty_tag_parameters) : lower(key)])
  non_empty_base_tags      = { for i, v in local.base_tags : i => v if v != null && v != "" && !contains(local.caller_tag_keys, lower(i)) }
  tags                     = merge(local.non_empty_base_tags, local.non_empty_tag_parameters)
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