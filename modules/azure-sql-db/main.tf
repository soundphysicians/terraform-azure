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

# ------------------------------------------------------------------------
# Stores the current connection information
# ------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

provider "azurerm" {
  skip_provider_registration = true
  alias                      = "audit"
  subscription_id            = try(var.auditing_storage_account.subscription_id, data.azurerm_client_config.current.subscription_id)
  features {}
}

# ------------------------------------------------------------------------
# Auditing Storage Account
#   Centralized storage for auditing logs
# ------------------------------------------------------------------------
data "azurerm_storage_account" "audit" {
  count               = var.environment == "prd" ? 1 : 0
  provider            = azurerm.audit
  name                = var.auditing_storage_account.storage_account_name
  resource_group_name = var.auditing_storage_account.resource_group_name
}

# ------------------------------------------------------------------------
# Azure SQL Server
#   Name: {prefix}-{env}-sqlserver-{base_name}
#   Example: sbs-tst-sqlserver-billing
# ------------------------------------------------------------------------
resource "azurecaf_name" "server" {
  resource_type = "azurerm_mssql_server"
  prefixes      = [var.prefix, var.environment]
  suffixes      = [var.base_name]
}

resource "random_password" "password" {
  length           = 32
  special          = true
  override_special = "_%@"
}

resource "azurerm_mssql_server" "server" {
  name                         = azurecaf_name.server.result
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  minimum_tls_version          = "1.2"
  administrator_login          = var.administrator_login
  administrator_login_password = random_password.password.result

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    login_username              = var.sql_ad_admin_username
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    object_id                   = var.sql_ad_admin_object_id
    azuread_authentication_only = false
  }

  lifecycle {
    ignore_changes = [
      # Ignore identity so TF doesn't consider it to be a change
      identity
    ]
  }

  tags = {
    environment = var.environment
    project     = var.prefix
  }
}

# ------------------------------------------------------------------------
# Azure SQL Server Auditing Policy - Production Only
# ------------------------------------------------------------------------
resource "azurerm_mssql_server_extended_auditing_policy" "server" {
  count                                   = var.environment == "prd" ? 1 : 0
  server_id                               = azurerm_mssql_server.server.id
  storage_endpoint                        = data.azurerm_storage_account.audit[0].primary_blob_endpoint
  storage_account_access_key              = data.azurerm_storage_account.audit[0].primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 0
}

# ------------------------------------------------------------------------
# Azure SQL Server Database
# ------------------------------------------------------------------------
resource "azurerm_mssql_database" "db" {
  name                 = var.application_name
  server_id            = azurerm_mssql_server.server.id
  sku_name             = var.sql_perf_level
  storage_account_type = "GRS" # Default: GRS

  tags = {
    environment = var.environment
    project     = var.prefix
  }
}

# ------------------------------------------------------------------------
# Azure SQL Database Auditing Policy - Production Only
# ------------------------------------------------------------------------
resource "azurerm_mssql_database_extended_auditing_policy" "db" {
  count                                   = var.environment == "prd" ? 1 : 0
  database_id                             = azurerm_mssql_database.db.id
  storage_endpoint                        = data.azurerm_storage_account.audit[0].primary_blob_endpoint
  storage_account_access_key              = data.azurerm_storage_account.audit[0].primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 0
}

# ------------------------------------------------------------------------
# Azure SQL Firewall Rules
# ------------------------------------------------------------------------
resource "azurerm_mssql_firewall_rule" "sql_firewall_allow_azure" {
  name             = "AllowAllAzureIP"
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "sql_firewall_rules" {
  for_each         = { for rule in var.firewall_rules : rule.name => rule }
  name             = each.key
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = each.value["start_ip_address"]
  end_ip_address   = each.value["end_ip_address"]
}
