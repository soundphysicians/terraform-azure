terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">= 1.2.11"
    }
  }
}

provider "azurerm" {
  alias           = "shared"
  subscription_id = var.subscription_id
  features {}
}

data "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  provider = azurerm.shared
}

resource "azurecaf_name" "registry" {
  resource_type = "azurerm_container_registry"
  prefixes      = [var.project, local.environment]
}

locals {
  environment   = "shr"
  registry_name = coalesce(var.name, azurecaf_name.registry.result)

  base_tags = {
    environment = local.environment,
    project     = var.project
  }

  non_empty_tag_parameters = { for i, v in coalesce(var.tags, {}) : i => v if v != null && v != "" }
  caller_tag_keys          = toset([for key in keys(local.non_empty_tag_parameters) : lower(key)])
  non_empty_base_tags      = { for i, v in local.base_tags : i => v if v != null && v != "" && !contains(local.caller_tag_keys, lower(i)) }
  tags                     = merge(local.non_empty_base_tags, local.non_empty_tag_parameters)
}

# ----------------------------------------------
# Container Registry 
# - Creates the following services in the tdd environment only
#   Azure Container Registry
# ----------------------------------------------
resource "azurerm_container_registry" "this" {
  count               = var.should_create ? 1 : 0
  provider            = azurerm.shared
  name                = local.registry_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      # Ignore identity_ids so TF doesn't consider it to be a change
      identity[0].identity_ids
    ]
  }

  tags = local.tags
}

# ----------------------------------------------
# Data for Container Registry 
# - Retrieves the container registry so we can 
#   get credentials to be used to download images
# ----------------------------------------------
data "azurerm_container_registry" "this" {
  provider            = azurerm.shared
  name                = local.registry_name
  resource_group_name = data.azurerm_resource_group.rg.name
}
