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
  key_vault                      = null
  app_settings                   = {}
  connection_strings             = []
  dotnet_framework_version       = null
  health_check_path              = null
}

run "should_create_web_app_with_reasonable_defaults" {
  command = plan

  variables {

  }

  assert {
    condition     = azurerm_app_service.webapp.name == "mie-tdd-webapp-test"
    error_message = "Should create app service with default naming convention"
  }
}

run "should_set_default_tags" {
  command = plan

  assert {
    condition     = lookup(azurerm_app_service.webapp.tags, "environment") == var.environment
    error_message = "Should set environment tag on web app"
  }

  assert {
    condition     = lookup(azurerm_app_service.webapp.tags, "project") == var.project
    error_message = "Should set project tag on web app"
  }

  assert {
    condition     = lookup(azurerm_user_assigned_identity.webapp.tags, "environment") == var.environment
    error_message = "Should set environment tag on identity"
  }

  assert {
    condition     = lookup(azurerm_app_service_plan.webapp.tags, "environment") == var.environment
    error_message = "Should set environment tag on plan"
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
    condition     = lookup(azurerm_app_service.webapp.tags, "cost-center") == "1234"
    error_message = "Should set cost-center tag on web app"
  }

  assert {
    condition     = lookup(azurerm_app_service.webapp.tags, "owner") == "platform-team"
    error_message = "Should set owner tag on web app"
  }

  assert {
    condition     = lookup(azurerm_app_service.webapp.tags, "environment") == var.environment
    error_message = "Should preserve environment tag on web app"
  }

  assert {
    condition     = lookup(azurerm_app_service.webapp.tags, "project") == var.project
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
    condition     = lookup(azurerm_app_service.webapp.tags, "Environment") == "custom-env"
    error_message = "Caller Environment tag should override base tag and preserve its key"
  }

  assert {
    condition     = lookup(azurerm_app_service.webapp.tags, "Project") == "custom-project"
    error_message = "Caller Project tag should override base tag and preserve its key"
  }

  assert {
    condition     = !contains(keys(azurerm_app_service.webapp.tags), "environment") && !contains(keys(azurerm_app_service.webapp.tags), "project")
    error_message = "Base tags should be removed when caller keys differ only by case"
  }
}

run "should_exclude_hideapp_tag_from_azuread_application_tags" {
  command = plan

  variables {
    tags = {
      "display" = "HideApp"
      "owner"   = "platform-team"
    }
  }

  assert {
    condition     = !contains(azuread_application.webapp.tags, "HideApp")
    error_message = "Should exclude HideApp from Azure AD application tags"
  }

  assert {
    condition     = contains(azuread_application.webapp.tags, "platform-team")
    error_message = "Should include non-HideApp tag values in Azure AD application tags"
  }

  assert {
    condition     = lookup(azurerm_app_service.webapp.tags, "display") == "HideApp"
    error_message = "Should preserve HideApp tag on ARM resource"
  }
}