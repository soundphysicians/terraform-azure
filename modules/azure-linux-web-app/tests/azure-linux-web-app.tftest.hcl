provider "azurerm" {
  features {}
}

variables {
  project                        = "Mercury"
  prefix                         = "mie"
  suffix                         = "test"
  environment                    = "tdd"
  resource_group_name            = "mie-tdd-rg"
  app_name                       = null
  plan_name                      = null
  custom_domain_name             = null
  devtest_port                   = 44399
  required_graph_access          = []
  supported_app_roles            = []
  test_automation_application_id = null
  app_role_assignments           = []
  key_vault = {
    name                = "mie-shr-kv"
    resource_group_name = "mie-shr-rg"
  }
  app_settings             = {}
  connection_strings       = []
  dotnet_framework_version = null
  health_check_path        = null
  web_app_sku_name         = "B2"
}

run "should_create_web_app_with_reasonable_defaults" {
  command = plan

  variables {

  }

  assert {
    condition     = azurerm_linux_web_app.webapp.name == "mie-tdd-webapp-test"
    error_message = "Should create app service with default naming convention"
  }

  assert {
    condition     = lookup(azurerm_linux_web_app.webapp.tags, "environment") == var.environment
    error_message = "Should set default environment tag"
  }

  assert {
    condition     = lookup(azurerm_linux_web_app.webapp.tags, "project") == var.project
    error_message = "Should set default project tag"
  }
}

run "should_merge_additional_tags" {
  command = plan

  variables {
    tags = {
      "cost_center" = "1234"
      "owner"       = "team-a"
    }
  }

  assert {
    condition     = lookup(azurerm_linux_web_app.webapp.tags, "cost_center") == "1234"
    error_message = "Should set cost_center tag on web app"
  }

  assert {
    condition     = lookup(azurerm_linux_web_app.webapp.tags, "owner") == "team-a"
    error_message = "Should set owner tag on web app"
  }

  assert {
    condition     = lookup(azurerm_linux_web_app.webapp.tags, "environment") == var.environment
    error_message = "Should preserve environment tag on web app"
  }

  assert {
    condition     = lookup(azurerm_linux_web_app.webapp.tags, "project") == var.project
    error_message = "Should preserve project tag on web app"
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
    condition     = lookup(azurerm_linux_web_app.webapp.tags, "Environment") == "custom-env"
    error_message = "Caller Environment tag should override base tag and preserve its key"
  }

  assert {
    condition     = lookup(azurerm_linux_web_app.webapp.tags, "Project") == "custom-project"
    error_message = "Caller Project tag should override base tag and preserve its key"
  }

  assert {
    condition     = !contains(keys(azurerm_linux_web_app.webapp.tags), "environment") && !contains(keys(azurerm_linux_web_app.webapp.tags), "project")
    error_message = "Base tags should be removed when caller keys differ only by case"
  }
}

run "should_not_pass_caller_tags_to_azuread_resources" {
  command = plan

  variables {
    tags = {
      "display" = "HideApp"
      "mdstaff" = "true"
      "owner"   = "platform-team"
    }
  }

  assert {
    condition     = toset(azuread_application.webapp.tags) == toset([var.environment, var.project])
    error_message = "Azure AD application should receive only base tag values"
  }

  assert {
    condition     = toset(azuread_service_principal.webapp.tags) == toset([var.environment, var.project])
    error_message = "Azure AD service principal should receive only base tag values"
  }

  assert {
    condition     = lookup(azurerm_linux_web_app.webapp.tags, "mdstaff") == "true" && lookup(azurerm_linux_web_app.webapp.tags, "owner") == "platform-team"
    error_message = "Should preserve caller tags on ARM resource"
  }
}