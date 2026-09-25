provider "azurerm" {
  features {}
}

override_data {
  target = data.azurerm_key_vault.key_vault
  values = {
    id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/sbs-dev-rg/providers/Microsoft.KeyVault/vaults/sbs-dev-kv"
    name = "sbs-dev-kv"
  }
}

override_data {
  target = data.azurerm_log_analytics_workspace.this
  values = {
    id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/sbs-dev-rg/providers/Microsoft.OperationalInsights/workspaces/sbs-dev-law"
    workspace_id       = "00000000-0000-0000-0000-000000000000"
    primary_shared_key = "dGVzdGtleQ=="
  }
}

variables {
  name        = "sbs-dev-ci-app"
  identity    = "sbs-dev-ci-app-identity"
  environment = "dev"
  project     = "sbs"
  resource_group = {
    name     = "sbs-dev-rg"
    location = "eastus2"
  }
  key_vault = {
    name                = "sbs-dev-kv"
    resource_group_name = "sbs-dev-rg"
  }
  log_analytics_workspace = {
    name                = "sbs-dev-law"
    resource_group_name = "sbs-dev-rg"
  }
  app_insights_telemetry_key         = "00000000-0000-0000-0000-000000000000"
  database_connection_string_name    = "db-conn"
  service_bus_connection_string_name = "sb-conn"
  container_image = {
    name    = "my-app"
    version = "latest"
  }
  container_registry = {
    login_server = "myregistry.azurecr.io"
    username     = "myregistry"
    password     = "secret"
  }
}

run "should_set_default_tags" {
  command = plan

  assert {
    condition     = lookup(azurerm_container_group.container.tags, "environment") == var.environment
    error_message = "Should set environment tag on container group"
  }

  assert {
    condition     = lookup(azurerm_container_group.container.tags, "project") == var.project
    error_message = "Should set project tag on container group"
  }

  assert {
    condition     = lookup(azurerm_user_assigned_identity.container.tags, "environment") == var.environment
    error_message = "Should set environment tag on identity"
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
    condition     = lookup(azurerm_container_group.container.tags, "cost-center") == "1234"
    error_message = "Should set cost-center tag on container group"
  }

  assert {
    condition     = lookup(azurerm_container_group.container.tags, "owner") == "platform-team"
    error_message = "Should set owner tag on container group"
  }

  assert {
    condition     = lookup(azurerm_container_group.container.tags, "environment") == var.environment
    error_message = "Should preserve environment tag on container group"
  }

  assert {
    condition     = lookup(azurerm_container_group.container.tags, "project") == var.project
    error_message = "Should preserve project tag on container group"
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
    condition     = lookup(azurerm_container_group.container.tags, "Environment") == "custom-env"
    error_message = "Caller Environment tag should override base tag and preserve its key"
  }

  assert {
    condition     = lookup(azurerm_container_group.container.tags, "Project") == "custom-project"
    error_message = "Caller Project tag should override base tag and preserve its key"
  }

  assert {
    condition     = !contains(keys(azurerm_container_group.container.tags), "environment") && !contains(keys(azurerm_container_group.container.tags), "project")
    error_message = "Base tags should be removed when caller keys differ only by case"
  }
}

run "should_set_tags_on_network_profile_when_vnet_integration_enabled" {
  command = plan

  variables {
    vnet_integration_enabled = true
    subnet_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/sbs-dev-rg/providers/Microsoft.Network/virtualNetworks/sbs-dev-vnet/subnets/sbs-dev-subnet"
    tags = {
      "cost-center" = "1234"
    }
  }

  assert {
    condition     = lookup(azurerm_network_profile.network_profile[0].tags, "cost-center") == "1234"
    error_message = "Should set cost-center tag on network profile"
  }

  assert {
    condition     = lookup(azurerm_network_profile.network_profile[0].tags, "environment") == var.environment
    error_message = "Should preserve environment tag on network profile"
  }

  assert {
    condition     = lookup(azurerm_network_profile.network_profile[0].tags, "project") == var.project
    error_message = "Should preserve project tag on network profile"
  }
}

run "should_handle_explicit_null_tags" {
  command = plan

  variables {
    tags = null
  }

  assert {
    condition     = lookup(azurerm_container_group.container.tags, "environment") == var.environment
    error_message = "Should set environment tag on container group when tags is null"
  }

  assert {
    condition     = lookup(azurerm_container_group.container.tags, "project") == var.project
    error_message = "Should set project tag on container group when tags is null"
  }
}
