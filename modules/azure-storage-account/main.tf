locals {
  # Lowercase values for use in resource names
  environment     = lower(var.name.environment == null ? "" : var.name.environment)
  prefix          = lower(var.name.prefix == null ? "" : var.name.prefix)
  clean_base_name = replace(var.name.base_name == null ? "" : var.name.base_name, "/[^a-zA-Z0-9]/", "")
  name_override   = lower(var.name.name_override == null ? "" : var.name.name_override)

  derived_tags = {
    environment = local.environment,
    project     = local.prefix
  }

  non_empty_tag_parameters = { for i, v in var.tags : i => v if v != null && v != "" }
  non_empty_derived_tags   = { for i, v in local.derived_tags : i => v if v != null && v != "" }
  tags                     = merge(local.non_empty_derived_tags, local.non_empty_tag_parameters)

  # Pass appsettings from variable with embedded defaults
  storage_account_name = lower(coalesce(local.name_override, "${local.prefix}${local.environment}sa${local.clean_base_name}"))
}

# ------------------------------------------------------------------------
# Storage Account
# ------------------------------------------------------------------------
resource "azurerm_storage_account" "this" {
  name                     = local.storage_account_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  access_tier              = "Hot"

  # Require HTTPS traffic only (no http traffic allowed)
  https_traffic_only_enabled = true

  # Require at least TLS 1.2
  min_tls_version = "TLS1_2"

  # Turn off anonymous access to blobs in the storage account
  allow_nested_items_to_be_public = false

  tags = local.tags
}
