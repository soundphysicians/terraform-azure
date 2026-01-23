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
  app_settings                   = {}
  connection_strings             = []
  dotnet_framework_version       = null
  health_check_path              = null
  web_app_sku_name               = "B2"
}

run "should_create_web_app_with_reasonable_defaults" {
  command = plan

  variables {

  }

  assert {
    condition     = azurerm_windows_web_app.webapp.name == "mie-tdd-webapp-test"
    error_message = "Should create app service with default naming convention"
  }

  assert {
    condition     = azurerm_windows_web_app.webapp.https_only == true
    error_message = "Should require HTTPS only"
  }

  assert {
    condition     = azurerm_windows_web_app.webapp.site_config[0].http2_enabled == true
    error_message = "Should enable HTTP2"
  }

  assert {
    condition     = azurerm_windows_web_app.webapp.site_config[0].minimum_tls_version == "1.2"
    error_message = "Should set minimum TLS version to 1.2"
  }

  assert {
    condition     = azurerm_service_plan.webapp.os_type == "Windows"
    error_message = "Should create Windows service plan"
  }
}

run "should_create_app_roles_when_provided" {
  command = plan

  variables {
    supported_app_roles = [
      {
        id           = "11111111-1111-1111-1111-111111111111"
        description  = "Admin role for the application"
        display_name = "Admin"
        enabled      = true
        value        = "Admin"
      },
      {
        id           = "22222222-2222-2222-2222-222222222222"
        description  = "User role for the application"
        display_name = "User"
        enabled      = true
        value        = "User"
      }
    ]
  }

  assert {
    condition     = length(azuread_application.webapp.app_role) == 2
    error_message = "Should create 2 app roles"
  }

  assert {
    condition     = contains([for role in azuread_application.webapp.app_role : role.value], "Admin")
    error_message = "Should include Admin role"
  }

  assert {
    condition     = contains([for role in azuread_application.webapp.app_role : role.value], "User")
    error_message = "Should include User role"
  }
}

run "should_assign_test_automation_roles_when_provided" {
  command = plan

  variables {
    test_automation_application_id = "841e82d1-f56e-4afe-8d67-e88623e099e1"
    supported_app_roles = [
      {
        id           = "44444444-4444-4444-4444-444444444444"
        description  = "Test role"
        display_name = "TestRole"
        enabled      = true
        value        = "TestRole"
      }
    ]
  }

  assert {
    condition     = length(azuread_app_role_assignment.test-automation) == 1
    error_message = "Should create 1 test automation role assignment"
  }

  assert {
    condition     = length(data.azuread_service_principal.test_automation) == 1
    error_message = "Should lookup test automation service principal"
  }
}

run "should_create_app_role_assignments_when_provided" {
  command = plan

  variables {
    supported_app_roles = [
      {
        id           = "55555555-5555-5555-5555-555555555555"
        description  = "Admin role"
        display_name = "Admin"
        enabled      = true
        value        = "Admin"
      },
      {
        id           = "66666666-6666-6666-6666-666666666666"
        description  = "Reader role"
        display_name = "Reader"
        enabled      = true
        value        = "Reader"
      }
    ]
    app_role_assignments = [
      {
        application_object_id = "77777777-7777-7777-7777-777777777777"
        role_ids              = ["55555555-5555-5555-5555-555555555555"]
      },
      {
        application_object_id = "88888888-8888-8888-8888-888888888888"
        role_ids              = ["55555555-5555-5555-5555-555555555555", "66666666-6666-6666-6666-666666666666"]
      }
    ]
  }

  assert {
    condition     = length(azuread_app_role_assignment.api-role-assignments) == 3
    error_message = "Should create 3 app role assignments (1 for first app, 2 for second app)"
  }
}

run "should_configure_dotnet_version" {
  command = plan

  variables {
    dotnet_framework_version = "v8.0"
  }

  assert {
    condition     = azurerm_windows_web_app.webapp.site_config[0].application_stack[0].dotnet_version == "v8.0"
    error_message = "Should set .NET version to v8.0"
  }

  assert {
    condition     = azurerm_windows_web_app.webapp.site_config[0].application_stack[0].current_stack == "dotnet"
    error_message = "Should set current stack to dotnet"
  }
}
