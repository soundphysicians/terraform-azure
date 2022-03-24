terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.97.0"
    }
  }
}

variable "environment" {
  type        = string
  description = "Azure Environment Name"
  nullable    = false
}

variable "project" {
  type        = string
  description = "Project Name"
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
  nullable    = false
}

variable "name" {
  type        = string
  description = "Container Registry Name. Must be alpha numeric only"
  nullable    = false
}

variable "subscription_id" {
  type        = string
  description = "The Container Registry subscription"
  nullable    = false
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

# ----------------------------------------------
# Container Registry 
# - Creates the following services in the tdd environment only
#   Azure Container Registry
# ----------------------------------------------
resource "azurerm_container_registry" "this" {
  count               = var.environment == "tdd" ? 1 : 0
  provider            = azurerm.shared
  name                = var.name
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
    environment = "shr",
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
  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
}

output "login_server" {
  value = data.azurerm_container_registry.this.login_server
}
output "admin_username" {
  value = data.azurerm_container_registry.this.admin_username
}

output "admin_password" {
  value = data.azurerm_container_registry.this.admin_password
}
