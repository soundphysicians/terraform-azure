provider "azurerm" {
  skip_provider_registration = true
  features {}
}

provider "azurecaf" {}

variables {
  prefix                   = "sbs"
  environment              = "tdd"
  location                 = "eastus2"
  resource_group_name      = "sbs-tdd-rg"
  base_name                = "billing"
  application_name         = "billingapp"
  sql_ad_admin_username    = "sqladmin@example.com"
  sql_ad_admin_object_id   = "00000000-0000-0000-0000-000000000000"
  auditing_storage_account = null
}

run "should_set_default_tags" {
  command = plan

  assert {
    condition     = lookup(azurerm_mssql_server.server.tags, "environment") == var.environment
    error_message = "Should set environment tag on SQL server"
  }

  assert {
    condition     = lookup(azurerm_mssql_server.server.tags, "project") == var.prefix
    error_message = "Should set project tag on SQL server"
  }

  assert {
    condition     = lookup(azurerm_mssql_database.db.tags, "environment") == var.environment
    error_message = "Should set environment tag on SQL database"
  }

  assert {
    condition     = lookup(azurerm_mssql_database.db.tags, "project") == var.prefix
    error_message = "Should set project tag on SQL database"
  }
}

run "should_allow_additional_tags" {
  command = plan

  variables {
    tags = {
      "cost-center" = "1234"
      "owner"       = "platform-team"
    }
  }

  assert {
    condition     = lookup(azurerm_mssql_server.server.tags, "cost-center") == "1234"
    error_message = "Should set cost-center tag on SQL server"
  }

  assert {
    condition     = lookup(azurerm_mssql_server.server.tags, "owner") == "platform-team"
    error_message = "Should set owner tag on SQL server"
  }

  assert {
    condition     = lookup(azurerm_mssql_server.server.tags, "environment") == var.environment
    error_message = "Should preserve environment tag on SQL server"
  }

  assert {
    condition     = lookup(azurerm_mssql_server.server.tags, "project") == var.prefix
    error_message = "Should preserve project tag on SQL server"
  }

  assert {
    condition     = lookup(azurerm_mssql_database.db.tags, "cost-center") == "1234"
    error_message = "Should set cost-center tag on SQL database"
  }

  assert {
    condition     = lookup(azurerm_mssql_database.db.tags, "owner") == "platform-team"
    error_message = "Should set owner tag on SQL database"
  }
}

run "should_allow_caller_tags_to_override_base_tags" {
  command = plan

  variables {
    tags = {
      "Environment" = "custom-env"
      "Project"     = "custom-project"
    }
  }

  assert {
    condition     = lookup(azurerm_mssql_server.server.tags, "Environment") == "custom-env"
    error_message = "Caller Environment tag should override base tag on server and preserve its key"
  }

  assert {
    condition     = lookup(azurerm_mssql_server.server.tags, "Project") == "custom-project"
    error_message = "Caller Project tag should override base tag on server and preserve its key"
  }

  assert {
    condition     = lookup(azurerm_mssql_database.db.tags, "Environment") == "custom-env"
    error_message = "Caller Environment tag should override base tag on database and preserve its key"
  }

  assert {
    condition     = lookup(azurerm_mssql_database.db.tags, "Project") == "custom-project"
    error_message = "Caller Project tag should override base tag on database and preserve its key"
  }

  assert {
    condition     = !contains(keys(azurerm_mssql_server.server.tags), "environment") && !contains(keys(azurerm_mssql_server.server.tags), "project")
    error_message = "Base tags should be removed from the server when caller keys differ only by case"
  }
}
