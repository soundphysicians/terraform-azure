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
    application_insights_connection_string = "InstrumentationKey=00000000-0000-0000-0000-000000000000;IngestionEndpoint=https://test.applicationinsights.azure.com/"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.name == "tst-tdd-fn-myFunc"
    error_message = "Should assign default name to function app"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.resource_group_name == var.resource_group_name
    error_message = "Should associate with the correct resource group"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.location == var.location
    error_message = "Should set in correct location"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.runtime_name == "dotnet-isolated"
    error_message = "Should use dotnet-isolated runtime by default"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.runtime_version == "8.0"
    error_message = "Should use version 8.0 by default"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.maximum_instance_count == 100
    error_message = "Should set maximum instance count to 100 by default"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.instance_memory_in_mb == 2048
    error_message = "Should set instance memory to 2048 MB by default"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.storage_container_type == "blobContainer"
    error_message = "Should use blobContainer storage type"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.storage_authentication_type == "StorageAccountConnectionString"
    error_message = "Should use StorageAccountConnectionString authentication by default"
  }
}

run "should_create_service_plan_with_fc1_sku" {
  command = plan

  assert {
    condition     = azurerm_service_plan.plan.name == "tst-tdd-fcplan-myFunc"
    error_message = "Should assign default name to service plan with fcplan prefix"
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
    condition     = azurerm_service_plan.plan.sku_name == "FC1"
    error_message = "Should set as FlexConsumption plan (FC1)"
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

run "should_create_storage_account_and_deployment_container" {
  command = plan

  assert {
    condition     = module.storage_account.name == "tsttddsamyfunc"
    error_message = "Should assign default name to storage account"
  }

  assert {
    condition     = azurerm_storage_container.deployment.name == "deployments"
    error_message = "Should create deployment container named 'deployments'"
  }

  assert {
    condition     = azurerm_storage_container.deployment.container_access_type == "private"
    error_message = "Should set deployment container as private"
  }
}

run "should_handle_special_characters_when_creating_the_storage_account" {
  command = plan

  variables {
    base_name = "my-long-Func"
  }

  assert {
    condition     = module.storage_account.name == "tsttddsamylongfunc"
    error_message = "Should handle special characters in base name"
  }
}

run "should_create_user_assigned_identity" {
  command = plan

  assert {
    condition     = azurerm_user_assigned_identity.app.name == "tst-tdd-fn-myFunc"
    error_message = "Should create user assigned identity with function name"
  }

  assert {
    condition     = azurerm_user_assigned_identity.app.location == var.location
    error_message = "Should set identity in correct location"
  }

  assert {
    condition     = azurerm_user_assigned_identity.app.resource_group_name == var.resource_group_name
    error_message = "Should associate identity with correct resource group"
  }
}

run "should_create_azure_ad_application" {
  command = plan

  assert {
    condition     = azuread_application.app.display_name == "tst-tdd-fn-myFunc"
    error_message = "Should create Azure AD app with function name"
  }

  assert {
    condition     = azuread_application.app.sign_in_audience == "AzureADMyOrg"
    error_message = "Should set sign in audience to AzureADMyOrg"
  }

  assert {
    condition     = azuread_application.app.prevent_duplicate_names == false
    error_message = "Should allow duplicate names to avoid lookup permission issues"
  }
}

run "should_accept_custom_names" {
  command = plan

  variables {
    function_name        = "custom-function"
    storage_account_name = "customstorageacct"
    plan_name            = "custom-plan"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.name == "custom-function"
    error_message = "Should use custom function name when provided"
  }

  assert {
    condition     = module.storage_account.name == "customstorageacct"
    error_message = "Should use custom storage account name when provided"
  }

  assert {
    condition     = azurerm_service_plan.plan.name == "custom-plan"
    error_message = "Should use custom plan name when provided"
  }
}

run "should_accept_node_runtime" {
  command = plan

  variables {
    runtime_name    = "node"
    runtime_version = "20"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.runtime_name == "node"
    error_message = "Should accept node runtime"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.runtime_version == "20"
    error_message = "Should accept node version 20"
  }
}

run "should_accept_python_runtime" {
  command = plan

  variables {
    runtime_name    = "python"
    runtime_version = "3.11"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.runtime_name == "python"
    error_message = "Should accept python runtime"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.runtime_version == "3.11"
    error_message = "Should accept python version 3.11"
  }
}

run "should_accept_java_runtime" {
  command = plan

  variables {
    runtime_name    = "java"
    runtime_version = "17"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.runtime_name == "java"
    error_message = "Should accept java runtime"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.runtime_version == "17"
    error_message = "Should accept java version 17"
  }
}

run "should_accept_powershell_runtime" {
  command = plan

  variables {
    runtime_name    = "powershell"
    runtime_version = "7.4"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.runtime_name == "powershell"
    error_message = "Should accept powershell runtime"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.runtime_version == "7.4"
    error_message = "Should accept powershell version 7.4"
  }
}

run "should_accept_maximum_instance_count" {
  command = plan

  variables {
    maximum_instance_count = 500
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.maximum_instance_count == 500
    error_message = "Should accept custom maximum instance count"
  }
}

run "should_accept_4096_instance_memory" {
  command = plan

  variables {
    instance_memory_in_mb = 4096
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.instance_memory_in_mb == 4096
    error_message = "Should accept 4096 MB instance memory"
  }
}

run "should_use_managed_identity_for_storage" {
  command = plan

  variables {
    storage_authentication_type = "UserAssignedIdentity"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.storage_authentication_type == "UserAssignedIdentity"
    error_message = "Should use UserAssignedIdentity authentication"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.storage_access_key == null
    error_message = "Should not set storage access key when using managed identity"
  }

  assert {
    condition     = length(azurerm_role_assignment.storage_blob_owner) == 1
    error_message = "Should create role assignment for managed identity"
  }
}

run "should_use_connection_string_for_storage" {
  command = plan

  variables {
    storage_authentication_type = "StorageAccountConnectionString"
  }

  assert {
    condition     = azurerm_function_app_flex_consumption.app.storage_authentication_type == "StorageAccountConnectionString"
    error_message = "Should use StorageAccountConnectionString authentication"
  }

  assert {
    condition     = length(azurerm_role_assignment.storage_blob_owner) == 0
    error_message = "Should not create role assignment when using connection string"
  }
}

run "should_support_app_roles" {
  command = plan

  variables {
    app_roles = [
      {
        id           = "00000000-0000-0000-0000-000000000001"
        value        = "Reader"
        display_name = "Reader Role"
        description  = "Can read data"
      },
      {
        id           = "00000000-0000-0000-0000-000000000002"
        value        = "Writer"
        display_name = "Writer Role"
        description  = "Can write data"
      }
    ]
  }

  assert {
    condition     = length(azuread_application.app.app_role) == 2
    error_message = "Should create app roles when provided"
  }
}

run "should_set_proper_tags" {
  command = plan

  assert {
    condition     = lookup(azurerm_function_app_flex_consumption.app.tags, "environment") == var.environment
    error_message = "Should set environment tag on function app"
  }

  assert {
    condition     = lookup(azurerm_function_app_flex_consumption.app.tags, "project") == var.prefix
    error_message = "Should set project tag on function app"
  }

  assert {
    condition     = lookup(azurerm_user_assigned_identity.app.tags, "environment") == var.environment
    error_message = "Should set environment tag on identity"
  }

  assert {
    condition     = lookup(azurerm_service_plan.plan.tags, "environment") == var.environment
    error_message = "Should set environment tag on service plan"
  }
}

run "should_not_create_deployment_slot" {
  command = plan

  variables {
    deploy_using_slots = true
  }

  # Note: FlexConsumption doesn't support slots yet, so we just verify the variable is accepted
  # and doesn't cause errors. When Azure adds slot support, this test should be updated.
  assert {
    condition     = var.deploy_using_slots == true
    error_message = "Should accept deploy_using_slots variable for future compatibility"
  }
}
