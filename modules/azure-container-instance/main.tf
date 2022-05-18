terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }
}

data "azurerm_client_config" "current" {}

# ------------------------------------------------------------------------
# KeyVault for secrets
# ------------------------------------------------------------------------
data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault.name
  resource_group_name = var.key_vault.resource_group_name
}

# ------------------------------------------------------------------------
# User assigned identity for container instance
# ------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "container" {
  name                = var.identity
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  tags = {
    environment = var.environment,
    project     = var.project
  }
}

# ------------------------------------------------------------------------
# Grant access to the key vault for the container identity
# ------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "container" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.container.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# ------------------------------------------------------------------------
# Log Analytics Workspace: destination for container events
# ------------------------------------------------------------------------
data "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_workspace.name
  resource_group_name = var.log_analytics_workspace.resource_group_name
}

locals {
  network_profile_name = "${var.name}-netprofile"
  nic_name             = "${var.name}-nic"
  ipconfig_name        = "${var.name}-ipconfig"
}

# ------------------------------------------------------------------------
# Container Network Profile - Only created for private networks
# ------------------------------------------------------------------------
resource "azurerm_network_profile" "network_profile" {
  count               = var.vnet_integration_enabled ? 1 : 0
  name                = local.network_profile_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  container_network_interface {
    name = local.nic_name

    ip_configuration {
      name      = local.ipconfig_name
      subnet_id = var.subnet_id
    }
  }
}

locals {
  environment_variables = merge({
    DatabaseConnectionStringName            = var.database_connection_string_name
    ServiceBusConnectionStringName          = var.service_bus_connection_string_name
    KeyVault__Enabled                       = true
    KeyVault__Name                          = data.azurerm_key_vault.key_vault.name
    Database__EnableDetailedErrors          = false
    Database__EnableSensitiveDataLogging    = false
    ApplicationInsights__InstrumentationKey = var.app_insights_telemetry_key
  }, coalesce(var.environment_variables, {}))
}

# ------------------------------------------------------------------------
# Container Instance
# ------------------------------------------------------------------------
resource "azurerm_container_group" "container" {
  name                = var.name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  os_type             = "Linux"
  ip_address_type     = var.subnet_id == null ? "Public" : "Private"
  network_profile_id  = var.subnet_id != null ? azurerm_network_profile.network_profile[0].id : null

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container.id]
  }

  container {
    name   = var.name
    image  = "${var.container_registry.login_server}/${var.container_image.name}:${var.container_image.version}"
    cpu    = "0.5"
    memory = "1.5"

    # we don't need any ports open, since we are only talking outward to SQL and ASB, but 
    # it is required by our terraform azure provider, so set up a high number port, but our container 
    # doesn't expose it, so there will be nothing made available by this  
    ports {
      port     = 65501
      protocol = "TCP"
    }

    environment_variables = local.environment_variables

    secure_environment_variables = var.secure_environment_variables
  }

  image_registry_credential {
    server   = var.container_registry.login_server
    username = var.container_registry.username
    password = var.container_registry.password
  }

  diagnostics {
    log_analytics {
      workspace_id  = data.azurerm_log_analytics_workspace.this.workspace_id
      workspace_key = data.azurerm_log_analytics_workspace.this.primary_shared_key
      metadata      = {}
    }
  }

  tags = {
    environment = var.environment,
    project     = var.project
  }
}
