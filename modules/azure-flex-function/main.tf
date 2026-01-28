terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
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
  base_app_settings = {
    AZURE_FUNCTIONS_ENVIRONMENT      = var.function_environment
    AZURE_CLIENT_ID                  = azurerm_user_assigned_identity.app.client_id
    AzureWebJobsStorage__accountName = module.storage_account.name
  }

  app_settings = merge(local.base_app_settings, coalesce(var.app_settings, {}))

  function_name          = coalesce(var.function_name, "${local.prefix}-${local.environment}-fn-${var.base_name}")
  storage_account_name   = lower(coalesce(var.storage_account_name, "${local.prefix}${local.environment}sa${local.clean_base_name}"))
  plan_name              = coalesce(var.plan_name, "${local.prefix}-${local.environment}-fcplan-${var.base_name}")
  deployment_container   = "deployments"
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

# ------------------------------------------------------------------------
# Deployment Storage Container (required for FlexConsumption)
# ------------------------------------------------------------------------
resource "azurerm_storage_container" "deployment" {
  name                  = local.deployment_container
  storage_account_id    = module.storage_account.id
  container_access_type = "private"
}

# ------------------------------------------------------------------------
# Service Plan (FlexConsumption)
# ------------------------------------------------------------------------
resource "azurerm_service_plan" "plan" {
  name                = local.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "FC1"

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
  prevent_duplicate_names        = false
  fallback_public_client_enabled = false
  tags                           = values(local.tags)

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2
    known_client_applications      = []
  }

  lifecycle {
    ignore_changes = [
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
# Function App (FlexConsumption)
# ------------------------------------------------------------------------
resource "azurerm_function_app_flex_consumption" "app" {
  name                = local.function_name
  resource_group_name = var.resource_group_name
  location            = var.location
  https_only          = true

  runtime_name           = var.runtime_name
  runtime_version        = var.runtime_version
  maximum_instance_count = var.maximum_instance_count
  instance_memory_in_mb  = var.instance_memory_in_mb

  site_config {
    http2_enabled = true

    remote_debugging_enabled = var.remote_debugging_enabled
    remote_debugging_version = "VS2022"

    application_insights_key               = var.app_insights_key
    application_insights_connection_string = var.application_insights_connection_string
  }

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${module.storage_account.primary_blob_endpoint}${local.deployment_container}"
  storage_authentication_type = var.storage_authentication_type
  storage_access_key          = var.storage_authentication_type == "StorageAccountConnectionString" ? module.storage_account.primary_access_key : null
  service_plan_id     = azurerm_service_plan.plan.id

  # Pass appsettings from variable with embedded defaults
  app_settings = local.app_settings

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
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
    azurerm_service_plan.plan,
    azurerm_storage_container.deployment
  ]

  tags = local.tags
}

# ------------------------------------------------------------------------
# Setup slot for function
# Note: FlexConsumption does not currently support deployment slots
# This is a placeholder for future support
# ------------------------------------------------------------------------
# resource "azurerm_function_app_flex_consumption_slot" "slot" {
#   count           = var.deploy_using_slots ? 1 : 0
#   function_app_id = azurerm_function_app_flex_consumption.app.id
#   name            = "staging"
#   # Configuration would mirror the main function app
# }

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
# Role Assignment: Storage Blob Data Owner (if using managed identity)
# ------------------------------------------------------------------------
resource "azurerm_role_assignment" "storage_blob_owner" {
  count                = var.storage_authentication_type == "SystemAssignedIdentity" || var.storage_authentication_type == "UserAssignedIdentity" ? 1 : 0
  scope                = module.storage_account.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
  principal_type       = "ServicePrincipal"
}
