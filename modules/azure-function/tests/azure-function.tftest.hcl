provider "azurerm" {
  features {}
}

variables {
  base_name           = "myFunc"
  prefix              = "tst"
  environment         = "tdd"
  location            = "westus3"
  resource_group_name = "tst-tdd-rg"
}

run "should_create_function_app_with_reasonable_defaults" {
  command = plan

  variables {
    app_insights_key = "1234567890"
  }

  assert {
    condition     = length(azurerm_linux_function_app_slot.slot) == 0
    error_message = "Should not create app slot"
  }

  assert {
    condition     = azurerm_linux_function_app.app.name == "tst-tdd-fn-myFunc"
    error_message = "Should assign default name to function app"
  }

  assert {
    condition     = azurerm_linux_function_app.app.resource_group_name == var.resource_group_name
    error_message = "Should associate with the correct resource group"
  }

  assert {
    condition     = azurerm_linux_function_app.app.https_only == true
    error_message = "Should require https only"
  }

  assert {
    condition     = azurerm_linux_function_app.app.enabled == true
    error_message = "Should be enabled automatically"
  }

  assert {
    condition     = azurerm_linux_function_app.app.location == var.location
    error_message = "Should set in correct location"
  }

  assert {
    condition     = azurerm_linux_function_app.app.functions_extension_version == "~4"
    error_message = "Should set as version 4 of functions extension"
  }

  assert {
    condition     = azurerm_linux_function_app.app.public_network_access_enabled == true
    error_message = "Should enable public access"
  }

  assert {
    condition     = azurerm_linux_function_app.app.site_config[0].minimum_tls_version == "1.2"
    error_message = "Should set minimum TLS version to 1.2"
  }

  assert {
    condition     = azurerm_linux_function_app.app.site_config[0].use_32_bit_worker == false
    error_message = "Should use 64 bit worker by default"
  }

  assert {
    condition     = azurerm_linux_function_app.app.site_config[0].websockets_enabled == false
    error_message = "Should not enable websockets by default"
  }

  assert {
    condition     = azurerm_linux_function_app.app.site_config[0].http2_enabled == true
    error_message = "Should enable http2 by default"
  }

  assert {
    condition     = azurerm_linux_function_app.app.site_config[0].ftps_state == "Disabled"
    error_message = "Should not enable ftps by default"
  }

  assert {
    condition     = azurerm_linux_function_app.app.site_config[0].application_insights_key == var.app_insights_key
    error_message = "Should set appinsights key when provided"
  }
}

run "should_create_storage_account_with_reasonable_defaults" {
  command = plan

  variables {
  }

  assert {
    condition     = azurerm_service_plan.plan.name == "tst-tdd-asplan-myFunc"
    error_message = "Should assign default name to service plan"
  }

  assert {
    condition     = azurerm_service_plan.plan.location == var.location
    error_message = "Should set in correct location"
  }

  assert {
    condition     = azurerm_service_plan.plan.resource_group_name == var.resource_group_name
    error_message = "Should associate with the correct resource group"
  }

  assert {
    condition     = azurerm_service_plan.plan.os_type == "Linux"
    error_message = "Should set as Linux service plan"
  }

  assert {
    condition     = azurerm_service_plan.plan.sku_name == "Y1"
    error_message = "Should set as basic consumption plan (Y1)"
  }

  assert {
    condition     = azurerm_storage_account.storage.name == "tsttddsamyfunc"
    error_message = "Should assign default name to storage account"
  }

  assert {
    condition     = lookup(azurerm_service_plan.plan.tags, "environment") == var.environment
    error_message = "Should set environment tag"
  }

  assert {
    condition     = lookup(azurerm_service_plan.plan.tags, "project") == var.prefix
    error_message = "Should set project tag"
  }
}

run "should_handle_special_characters_when_creating_the_storage_account" {
  command = plan

  variables {
    base_name = "my-long-Func"
  }

  assert {
    condition     = azurerm_storage_account.storage.name == "tsttddsamylongfunc"
    error_message = "Should handle special characters in base name"
  }
}


run "should_create_function_app_slot_with_reasonable_defaults" {
  command = plan

  variables {
    deploy_using_slots = true
  }


  assert {
    condition     = length(azurerm_linux_function_app_slot.slot) == 1
    error_message = "Should create app slot"
  }

  assert {
    condition     = azurerm_linux_function_app_slot.slot[0].name == "staging"
    error_message = "Should assign default name 'staging' to slot"
  }

  assert {
    condition     = azurerm_linux_function_app_slot.slot[0].https_only == true
    error_message = "Should require https only"
  }

  assert {
    condition     = azurerm_linux_function_app_slot.slot[0].enabled == true
    error_message = "Should be enabled automatically"
  }

  assert {
    condition     = azurerm_linux_function_app_slot.slot[0].functions_extension_version == "~4"
    error_message = "Should set as version 4 of functions extension"
  }

  assert {
    condition     = azurerm_linux_function_app_slot.slot[0].public_network_access_enabled == true
    error_message = "Should enable public access"
  }

  assert {
    condition     = azurerm_linux_function_app_slot.slot[0].site_config[0].minimum_tls_version == "1.2"
    error_message = "Should set minimum TLS version to 1.2"
  }

  assert {
    condition     = azurerm_linux_function_app_slot.slot[0].site_config[0].use_32_bit_worker == false
    error_message = "Should use 64 bit worker by default"
  }

  assert {
    condition     = azurerm_linux_function_app_slot.slot[0].site_config[0].websockets_enabled == false
    error_message = "Should not enable websockets by default"
  }

  assert {
    condition     = azurerm_linux_function_app_slot.slot[0].site_config[0].http2_enabled == true
    error_message = "Should enable http2 by default"
  }

  assert {
    condition     = azurerm_linux_function_app_slot.slot[0].site_config[0].ftps_state == "Disabled"
    error_message = "Should not enable ftps by default"
  }
}
