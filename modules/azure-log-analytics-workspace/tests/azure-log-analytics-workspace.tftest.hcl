provider "azurerm" {
  features {}
}

run "should_create_log_analytics_workspace_when_create_in_environment_is_true" {
  command = plan

  variables {
    location              = "westus2"
    project               = "mie"
    environment           = "tdd"
    create_in_environment = true
    sku                   = "PerGB2018"
    retention_in_days     = 30
    resource_group_name   = "mie-shr-rg-salesforce"
    workspace_name        = "mie-shr-law"
  }

  assert {
    condition     = output.workspace_name == var.workspace_name
    error_message = "Should return workspace name"
  }

  assert {
    condition     = length(azurerm_log_analytics_workspace.this) == 1
    error_message = "Should create log analytics workspace"
  }

  assert {
    condition     = length(data.azurerm_log_analytics_workspace.this) == 0
    error_message = "Should not reference existing log analytics workspace"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this[0].resource_group_name == var.resource_group_name
    error_message = "Should set resource group appropriately"
  }
}

run "should_not_create_log_analytics_workspace_when_create_in_environment_is_false" {
  command = plan

  variables {
    location              = "westus2"
    project               = "mie"
    environment           = "tdd"
    create_in_environment = false
    sku                   = "PerGB2018"
    retention_in_days     = 30
    resource_group_name   = "mie-shr-rg-salesforce"
    workspace_name        = "mie-shr-law"
  }

  assert {
    condition     = output.workspace_name == var.workspace_name
    error_message = "Should return workspace name"
  }

  assert {
    condition     = length(azurerm_log_analytics_workspace.this) == 0
    error_message = "Should not create log analytics workspace"
  }

  assert {
    condition     = length(data.azurerm_log_analytics_workspace.this) == 1
    error_message = "Should reference existing log analytics workspace"
  }
}

run "should_set_appropriate_defaults" {
  command = plan

  variables {
    location            = "westus2"
    project             = "mie"
    environment         = "tdd"
    resource_group_name = "mie-shr-rg-salesforce"
    workspace_name      = "mie-shr-law"
  }

  assert {
    condition     = length(azurerm_log_analytics_workspace.this) == 1
    error_message = "Should create by default"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this[0].sku == "PerGB2018"
    error_message = "Should set sku to PerGB2018 by default"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this[0].retention_in_days == 30
    error_message = "Should set retention to 30 days"
  }
}