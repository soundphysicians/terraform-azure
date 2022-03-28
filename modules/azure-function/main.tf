terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.97.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.11"
    }
  }
}

# ------------------------------------------------------------------------
# Stores the current connection information (Resource Manager and AD)
# ------------------------------------------------------------------------
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

# ------------------------------------------------------------------------
# Storage Account for Function App
# ------------------------------------------------------------------------
resource "azurecaf_name" "storage" {
  resource_type = "azurerm_storage_account"
  prefixes      = [var.project, var.environment]
  suffixes      = [var.base_name]
}

resource "azurerm_storage_account" "storage" {
  name                     = azurecaf_name.storage.result
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  access_tier              = "Hot"

  enable_https_traffic_only = "true"

  tags = {
    environment = var.environment
    project     = var.prefix
  }
}

# ------------------------------------------------------------------------
# Service Plan
# ------------------------------------------------------------------------
resource "azurecaf_name" "plan" {
  resource_type = "azurerm_app_service_plan"
  prefixes      = [var.prefix, var.environment]
  suffixes      = [var.base_name]
}

resource "azurerm_app_service_plan" "plan" {
  name                = azurecaf_name.plan.result
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

  tags = {
    environment = var.environment
    project     = var.prefix
  }
}

locals {
  # Pass appsettings from variable with embedded defaults
  app_settings = merge({
    APPINSIGHTS_INSTRUMENTATIONKEY = var.app_insights_key
    AZURE_FUNCTIONS_ENVIRONMENT    = var.function_environment
    FUNCTIONS_WORKER_RUNTIME       = "dotnet"
  }, coalesce(var.app_settings, {}))
}

# ------------------------------------------------------------------------
# Azure AD Application Registration
# ------------------------------------------------------------------------
resource "azuread_application" "app" {
  display_name                   = azurecaf_name.fn.result
  group_membership_claims        = ["None"]
  owners                         = [data.azuread_client_config.current.object_id]
  sign_in_audience               = "AzureADMyOrg"
  prevent_duplicate_names        = false # prevent lookups that we may not have rights to make
  fallback_public_client_enabled = false
  tags                           = [var.environment, var.prefix]

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2
    known_client_applications      = []
  }

  lifecycle {
    ignore_changes = [
      # Ignore identifier_urls so TF try to update, since it is calculated
      identifier_uris,
      id
    ]
  }

  dynamic "app_role" {
    for_each = { for x in var.app_roles : x.value => x }
    iterator = role
    content {
      id                   = role.value["id"]
      allowed_member_types = ["Application"]
      value                = role.key
      enabled              = true
      display_name         = role.value["display_name"]
      description          = coalesce(role.value["description"], role.value["display_name"])
    }
  }
}

# ------------------------------------------------------------------------
# Function App Service Principal
# ------------------------------------------------------------------------
resource "azuread_service_principal" "app" {
  application_id               = azuread_application.app.application_id
  app_role_assignment_required = false
  alternative_names            = []
  notification_email_addresses = []
  owners                       = [data.azuread_client_config.current.object_id]
  tags                         = [var.environment, var.prefix]

  lifecycle {
    ignore_changes = [
      id
    ]
  }
}

# ------------------------------------------------------------------------
# Function App
# ------------------------------------------------------------------------
resource "azurecaf_name" "fn" {
  resource_type = "azurerm_function_app"
  prefixes      = [var.project, var.environment]
  suffixes      = [var.base_name]
}

resource "azurerm_function_app" "app" {
  name                = azurecaf_name.fn.result
  location            = var.location
  resource_group_name = var.resource_group_name
  version             = "~4"
  https_only          = true
  site_config {
    app_scale_limit = 1
    http2_enabled   = true
    min_tls_version = 1.2
  }

  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  app_service_plan_id        = azurerm_app_service_plan.plan.id

  # Pass appsettings from variable with embedded defaults
  app_settings = local.app_settings

  identity {
    type = "SystemAssigned"
  }

  # TODO: re-enable auth once we get this into test without authn/authz enabled
  auth_settings {
    enabled = false
    active_directory {
      client_id         = azuread_application.app.application_id
      allowed_audiences = []
    }
    default_provider = "AzureActiveDirectory"
  }

  lifecycle {
    ignore_changes = [
      id,
      # ignore changes that the function app deployment manages
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      app_settings["WEBSITE_ENABLE_SYNC_UPDATE_SITE"]
    ]
  }

  depends_on = [
    azurerm_storage_account.storage,
    azurerm_app_service_plan.plan
  ]

  tags = {
    environment = var.environment
    project     = var.prefix
  }
}

# ------------------------------------------------------------------------
# Setup slot for function
# ------------------------------------------------------------------------
resource "azurerm_function_app_slot" "slot" {
  count               = var.environment == "prd" || var.environment == "tst" ? 1 : 0
  function_app_name   = azurerm_function_app.app.name
  name                = "staging"
  location            = var.location
  resource_group_name = var.resource_group_name
  version             = "~4"
  https_only          = true
  site_config {
    app_scale_limit = 1
    http2_enabled   = true
    min_tls_version = 1.2
  }

  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  app_service_plan_id        = azurerm_app_service_plan.plan.id

  app_settings = local.app_settings

  identity {
    type = "SystemAssigned"
  }

  auth_settings {
    enabled = false
    active_directory {
      client_id         = azuread_application.app.application_id
      allowed_audiences = []
    }
    default_provider = "AzureActiveDirectory"
  }

  lifecycle {
    ignore_changes = [
      id,
      # ignore changes that the function app deployment manages
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      app_settings["WEBSITE_ENABLE_SYNC_UPDATE_SITE"]
    ]
  }

  depends_on = [
    azurerm_storage_account.storage,
    azurerm_app_service_plan.plan
  ]

  tags = {
    environment = var.environment
    project     = var.prefix
  }
}

# ------------------------------------------------------------------------
# KeyVault for secrets
# ------------------------------------------------------------------------
data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault.name
  resource_group_name = var.key_vault.resource_group_name
}

# ------------------------------------------------------------------------
# Grant access to the key vault for the primary function
# ------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "app" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_function_app.app.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# ------------------------------------------------------------------------
# Grant access to the key vault for the slot function, if we have one
# ------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "slot" {
  count        = var.environment == "prd" || var.environment == "tst" ? 1 : 0
  key_vault_id = data.azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_function_app_slot.slot[0].identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}
