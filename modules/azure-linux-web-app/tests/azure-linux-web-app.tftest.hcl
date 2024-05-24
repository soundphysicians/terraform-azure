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
    condition     = azurerm_linux_web_app.webapp.name == "mie-tdd-webapp-test"
    error_message = "Should create app service with default naming convention"
  }
}