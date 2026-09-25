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

run "should_set_default_tags" {
  command = plan

  variables {
    location            = "westus2"
    project             = "mie"
    environment         = "tdd"
    resource_group_name = "mie-shr-rg-salesforce"
    workspace_name      = "mie-shr-law"
  }

  assert {
    condition     = lookup(azurerm_log_analytics_workspace.this[0].tags, "environment") == "tdd"
    error_message = "Should set environment tag on workspace"
  }

  assert {
    condition     = lookup(azurerm_log_analytics_workspace.this[0].tags, "project") == "mie"
    error_message = "Should set project tag on workspace"
  }
}

run "should_allow_additional_tags" {
  command = plan

  variables {
    location            = "westus2"
    project             = "mie"
    environment         = "tdd"
    resource_group_name = "mie-shr-rg-salesforce"
    workspace_name      = "mie-shr-law"
    tags = {
      "cost-center" = "1234"
      "owner"       = "platform-team"
    }
  }

  assert {
    condition     = lookup(azurerm_log_analytics_workspace.this[0].tags, "cost-center") == "1234"
    error_message = "Should set cost-center tag on workspace"
  }

  assert {
    condition     = lookup(azurerm_log_analytics_workspace.this[0].tags, "owner") == "platform-team"
    error_message = "Should set owner tag on workspace"
  }

  assert {
    condition     = lookup(azurerm_log_analytics_workspace.this[0].tags, "environment") == "tdd"
    error_message = "Should preserve environment tag on workspace"
  }

  assert {
    condition     = lookup(azurerm_log_analytics_workspace.this[0].tags, "project") == "mie"
    error_message = "Should preserve project tag on workspace"
  }
}

run "should_allow_caller_tags_to_override_base_tags" {
  command = plan

  variables {
    location            = "westus2"
    project             = "mie"
    environment         = "tdd"
    resource_group_name = "mie-shr-rg-salesforce"
    workspace_name      = "mie-shr-law"
    tags = {
      "Environment" = "custom-env"
      "Project"     = "custom-project"
    }
  }

  assert {
    condition     = lookup(azurerm_log_analytics_workspace.this[0].tags, "Environment") == "custom-env"
    error_message = "Caller Environment tag should override base tag and preserve its key"
  }

  assert {
    condition     = lookup(azurerm_log_analytics_workspace.this[0].tags, "Project") == "custom-project"
    error_message = "Caller Project tag should override base tag and preserve its key"
  }

  assert {
    condition     = !contains(keys(azurerm_log_analytics_workspace.this[0].tags), "environment") && !contains(keys(azurerm_log_analytics_workspace.this[0].tags), "project")
    error_message = "Base tags should be removed when caller keys differ only by case"
  }
}