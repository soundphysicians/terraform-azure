terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.97"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">= 1.2.11"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  alias                      = "shared"
  subscription_id            = var.subscription_id
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

  tags = {
    environment = local.environment,
    project     = var.project
  }
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
