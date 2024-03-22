terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }
}

# ------------------------------------------------------------------------
# Stores the current connection information (Resource Manager and AD)
# ------------------------------------------------------------------------
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

locals {
  # Lowercase values for use in resource names
  environment     = lower(var.environment)
  prefix          = lower(var.prefix)
  clean_base_name = replace(var.base_name, "/[^a-zA-Z0-9]/", "")

  tags = {
    environment = local.environment
    project     = local.prefix
  }

  # Pass appsettings from variable with embedded defaults
  app_settings = merge({
    APPINSIGHTS_INSTRUMENTATIONKEY = var.app_insights_key
    AZURE_FUNCTIONS_ENVIRONMENT    = var.function_environment
    FUNCTIONS_WORKER_RUNTIME       = "dotnet"
    AZURE_CLIENT_ID                = azurerm_user_assigned_identity.app.client_id
  }, coalesce(var.app_settings, {}))

  function_name        = coalesce(var.function_name, "${local.prefix}-${local.environment}-fn-${var.base_name}")
  storage_account_name = lower(coalesce(var.function_name, "${local.prefix}${local.environment}sa${local.clean_base_name}"))
  plan_name            = coalesce(var.plan_name, "${local.prefix}-${local.environment}-asplan-${var.base_name}")
}

# ------------------------------------------------------------------------
# Storage Account for Function App
# ------------------------------------------------------------------------
module "storage_account" {
  source              = "../azure-storage-account"
  resource_group_name = var.resource_group_name
  location            = var.location
  name = {
    environment   = local.environment
    prefix        = local.prefix
    base_name     = var.base_name
    name_override = local.storage_account_name
  }
}

moved {
  from = azurerm_storage_account.storage
  to   = module.storage_account.azurerm_storage_account.this
}

# ------------------------------------------------------------------------
# Service Plan
# ------------------------------------------------------------------------
resource "azurerm_service_plan" "plan" {
  name                = local.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "Y1"

  tags = local.tags
}

# ------------------------------------------------------------------------
# Azure AD Application Registration
# ------------------------------------------------------------------------
resource "azuread_application" "app" {
  display_name                   = local.function_name
  group_membership_claims        = ["None"]
  owners                         = [data.azuread_client_config.current.object_id]
  sign_in_audience               = "AzureADMyOrg"
  prevent_duplicate_names        = false # prevent lookups that we may not have rights to make
  fallback_public_client_enabled = false
  tags                           = values(local.tags)

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
  client_id                    = azuread_application.app.client_id
  app_role_assignment_required = false
  alternative_names            = []
  notification_email_addresses = []
  owners                       = [data.azuread_client_config.current.object_id]
  tags                         = values(local.tags)

  lifecycle {
    ignore_changes = [
      id
    ]
  }
}

# ------------------------------------------------------------------------
# User assigned identity for function
# ------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "app" {
  name                = local.function_name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = local.tags
}

# ------------------------------------------------------------------------
# Function App
# ------------------------------------------------------------------------
resource "azurerm_windows_function_app" "app" {
  name                    = local.function_name
  resource_group_name     = var.resource_group_name
  location                = var.location
  https_only              = true
  builtin_logging_enabled = true

  functions_extension_version     = "~4"
  public_network_access_enabled   = true
  key_vault_reference_identity_id = azurerm_user_assigned_identity.app.id

  site_config {
    app_scale_limit = var.app_scale_limit
    http2_enabled   = true

    # Should use 64 bit worker by default
    use_32_bit_worker = false

    remote_debugging_enabled = var.remote_debugging_enabled
    remote_debugging_version = "VS2022"

    application_insights_key = var.app_insights_key

    application_stack {
      dotnet_version              = var.dotnet_version
      use_dotnet_isolated_runtime = var.use_dotnet_isolated_runtime
    }
  }

  storage_account_name       = module.storage_account.name
  storage_account_access_key = module.storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.plan.id

  # Pass appsettings from variable with embedded defaults
  app_settings = local.app_settings

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  auth_settings {
    enabled = false
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
    azurerm_service_plan.plan
  ]

  tags = local.tags
}

# ------------------------------------------------------------------------
# Setup slot for function
# ------------------------------------------------------------------------
resource "azurerm_windows_function_app_slot" "slot" {
  count           = var.deploy_using_slots ? 1 : 0
  function_app_id = azurerm_windows_function_app.app.id
  name            = "staging"
  https_only      = true

  functions_extension_version     = "~4"
  public_network_access_enabled   = true
  key_vault_reference_identity_id = azurerm_user_assigned_identity.app.id

  site_config {
    app_scale_limit = var.app_scale_limit
    http2_enabled   = true

    # Should use 64 bit worker by default
    use_32_bit_worker = false

    remote_debugging_enabled = var.remote_debugging_enabled
    remote_debugging_version = "VS2022"

    application_insights_key = var.app_insights_key

    application_stack {
      dotnet_version              = var.dotnet_version
      use_dotnet_isolated_runtime = var.use_dotnet_isolated_runtime
    }
  }

  storage_account_name       = module.storage_account.name
  storage_account_access_key = module.storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.plan.id

  app_settings = local.app_settings

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  auth_settings {
    enabled = false
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
    azurerm_service_plan.plan
  ]

  tags = local.tags
}

# ------------------------------------------------------------------------
# KeyVault for secrets
# ------------------------------------------------------------------------
data "azurerm_key_vault" "key_vault" {
  count               = var.key_vault != null ? 1 : 0
  name                = var.key_vault.name
  resource_group_name = var.key_vault.resource_group_name
}

# ------------------------------------------------------------------------
# Grant access to the key vault for the primary function
# ------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "app" {
  count        = var.key_vault != null ? 1 : 0
  key_vault_id = data.azurerm_key_vault.key_vault[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.app.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# ------------------------------------------------------------------------
# Grant access to the key vault for the slot function, if we have one
# ------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "slot" {
  count        = var.key_vault != null ? length(azurerm_windows_function_app_slot.slot) : 0
  key_vault_id = data.azurerm_key_vault.key_vault[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.app.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}
