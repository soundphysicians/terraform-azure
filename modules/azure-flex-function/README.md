# Azure FlexConsumption Function App Module

This Terraform module creates an Azure Function App using the FlexConsumption (FC1) hosting plan. The FlexConsumption plan is designed for serverless workloads with improved scale and performance characteristics compared to the traditional Consumption (Y1) plan.

## Features

- FlexConsumption (FC1) hosting plan
- User-assigned managed identity
- Azure AD application registration and service principal
- Storage account with deployment container
- Application Insights integration (supports both instrumentation key and connection string)
- Key Vault access policy (optional)
- Configurable runtime and scaling settings
- Support for multiple authentication types for storage (connection string or managed identity)
- Full feature parity with azure-linux-function module (except deployment slots - not yet supported by FlexConsumption)
- Automatic role assignment for managed identity storage access
- Support for custom app settings and environment variables
- Support for Azure AD app roles

## Key Differences from Consumption Plan

The FlexConsumption plan differs from the traditional Consumption plan:

- Uses `azurerm_function_app_flex_consumption` resource instead of `azurerm_linux_function_app`
- Requires a dedicated deployment storage container
- Supports configurable instance memory (2048 MB or 4096 MB)
- Allows higher maximum instance counts (40-1000 instances)
- Provides more granular runtime configuration

## Usage

```hcl
module "flex_function" {
  source = "./modules/azure-flex-function"

  prefix              = "myapp"
  environment         = "prod"
  base_name           = "myfunction"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.example.name

  runtime_name                           = "dotnet-isolated"
  runtime_version                        = "8.0"
  maximum_instance_count                 = 100
  instance_memory_in_mb                  = 2048
  application_insights_connection_string = azurerm_application_insights.example.connection_string

  app_settings = {
    "CUSTOM_SETTING" = "value"
  }
}
```

## Example with Managed Identity Authentication

```hcl
module "flex_function" {
  source = "./modules/azure-flex-function"

  prefix              = "myapp"
  environment         = "prod"
  base_name           = "myfunction"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.example.name

  runtime_name                           = "node"
  runtime_version                        = "20"
  storage_authentication_type            = "UserAssignedIdentity"
  application_insights_connection_string = azurerm_application_insights.example.connection_string
}
```

## Supported Runtimes

The module supports the following runtime configurations:

| Runtime | Supported Versions |
|---------|-------------------|
| dotnet-isolated | 8.0, 9.0 |
| node | 18, 20 |
| python | 3.10, 3.11, 3.12 |
| java | 11, 17, 21 |
| powershell | 7.4 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prefix | Prefix to apply to all resource names | `string` | n/a | yes |
| environment | Name of the environment to deploy to | `string` | n/a | yes |
| base_name | Discriminator name for all resources | `string` | n/a | yes |
| location | Location to deploy resources to | `string` | n/a | yes |
| resource_group_name | Name of the resource group to place resources in | `string` | n/a | yes |
| function_name | Name of the function app to deploy | `string` | `null` | no |
| storage_account_name | Name of the storage account to use for the function app | `string` | `null` | no |
| plan_name | Name of the service plan to use for the function app | `string` | `null` | no |
| app_insights_key | Instrumentation key for the Application Insights instance | `string` | `null` | no |
| application_insights_connection_string | Connection string for the Application Insights instance | `string` | `null` | no |
| function_environment | Environment name for the function app (Development, Staging, Production) | `string` | `"Development"` | no |
| runtime_name | The name of the language worker runtime | `string` | `"dotnet-isolated"` | no |
| runtime_version | The version of the language worker runtime | `string` | `"8.0"` | no |
| maximum_instance_count | The maximum number of instances to scale to | `number` | `100` | no |
| instance_memory_in_mb | The memory size of instances (2048 or 4096) | `number` | `2048` | no |
| storage_authentication_type | Authentication type for storage account | `string` | `"StorageAccountConnectionString"` | no |
| app_settings | Key value pairs of application settings | `map(string)` | `{}` | no |
| app_roles | List of Application scoped roles to support | `list(object)` | `[]` | no |
| key_vault | Key vault to get secrets from | `object` | `null` | no |
| deploy_using_slots | Whether to deploy using slots (placeholder - not yet supported) | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Function App |
| name | The name of the Function App |
| default_hostname | The default hostname of the Function App |
| identity_principal_id | The principal ID of the user assigned identity |
| identity_client_id | The client ID of the user assigned identity |
| identity_id | The ID of the user assigned identity |
| storage_account_name | The name of the storage account used by the Function App |
| storage_account_id | The ID of the storage account used by the Function App |
| service_plan_id | The ID of the service plan |
| service_plan_name | The name of the service plan |
| app_registration_client_id | The client ID of the Azure AD application registration |
| app_registration_object_id | The object ID of the Azure AD application registration |
| service_principal_object_id | The object ID of the service principal |

## Resource Naming Convention

Given the following inputs:
- prefix: `myapp`
- environment: `prod`
- base_name: `myfunction`

The module will create resources with these names:
- Function name: `myapp-prod-fn-myfunction`
- Storage account: `myappprodsamyfunction`
- Service plan: `myapp-prod-fcplan-myfunction`

## Notes

- This module is specifically for FlexConsumption (FC1) plans
- For traditional Consumption (Y1) plans, use the `azure-linux-function` module instead
- The FlexConsumption plan runs on Linux only
- A deployment storage container is automatically created and configured
- When using managed identity authentication, appropriate role assignments are created automatically
- Deployment slots are not yet supported by Azure for FlexConsumption plans (the `deploy_using_slots` variable is a placeholder for future support)
- The module supports both App Insights instrumentation key and connection string for backward compatibility
- All app settings from the original azure-linux-function module are supported
- The module includes Azure AD application registration and service principal for authentication scenarios

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 4.0 |
| azuread | >= 2.0 |
