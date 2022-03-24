# ------------------------------------------------------------------------
# Stores the current connection information
# ------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

provider "azurerm" {
  skip_provider_registration = true
  alias                      = "audit"
  subscription_id            = var.auditing_storage_account.subscription_id
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
resource "azurerm_mssql_server" "server" {
  name                         = "${var.prefix}-${var.environment}-sqlserver-${var.base_name}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  minimum_tls_version          = "1.2"
  administrator_login          = var.sql_admin_username_secret.value
  administrator_login_password = var.sql_admin_password_secret.value

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
#   Name: {prefix}-{env}-sqlserver-{name}
#   Example: sbs-tst-sqlserver-billing
# ------------------------------------------------------------------------
resource "azurerm_mssql_database" "db" {
  name                 = "${var.prefix}-${var.environment}-sqldb-${var.base_name}"
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

resource "azurerm_mssql_firewall_rule" "sql_firewall_tacoma_office" {
  name             = "TacomaOffice"
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = "205.182.167.11"
  end_ip_address   = "205.182.167.11"
}

resource "azurerm_mssql_firewall_rule" "sql_firewall_remote_desktop" {
  name             = "RemoteDesktop"
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = "4.31.201.91"
  end_ip_address   = "4.31.201.91"
}

output "sql_fully_qualified_domain_name" {
  value       = azurerm_mssql_server.server.fully_qualified_domain_name
  description = "The fully qualified domain name of the SQL server"
  sensitive   = false
}

output "sql_database_name" {
  value       = azurerm_mssql_database.db.name
  description = "The name of the database on the Azure SQL server"
  sensitive   = false
}
