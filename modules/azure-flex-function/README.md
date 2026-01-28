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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | ../azure-storage-account | n/a |

## Resources

| Name | Type |
|------|------|
| [azuread_application.app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_service_principal.app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_function_app_flex_consumption.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app_flex_consumption) | resource |
| [azurerm_key_vault_access_policy.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_role_assignment.storage_blob_owner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_service_plan.plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_container.deployment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_user_assigned_identity.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_insights_key"></a> [app\_insights\_key](#input\_app\_insights\_key) | Instrumentation key for the Application Insights instance to use for logging | `string` | `null` | no |
| <a name="input_app_roles"></a> [app\_roles](#input\_app\_roles) | List of Application scoped roles to support | <pre>list(object({<br/>    id : string,<br/>    value : string,<br/>    display_name : string,<br/>    description : string<br/>  }))</pre> | `[]` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Key value pairs of application settings to apply to the function application | `map(string)` | `{}` | no |
| <a name="input_application_insights_connection_string"></a> [application\_insights\_connection\_string](#input\_application\_insights\_connection\_string) | Connection string for the Application Insights instance to use for logging | `string` | `null` | no |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | Discriminator name for all resources | `string` | n/a | yes |
| <a name="input_deploy_using_slots"></a> [deploy\_using\_slots](#input\_deploy\_using\_slots) | Whether or not to deploy the function app using deployment slots. If true, a staging slot will be created. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment to deploy to | `string` | n/a | yes |
| <a name="input_function_environment"></a> [function\_environment](#input\_function\_environment) | Prefix of the environment to deploy the function app to | `string` | `"Development"` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the function app to deploy | `string` | `null` | no |
| <a name="input_instance_memory_in_mb"></a> [instance\_memory\_in\_mb](#input\_instance\_memory\_in\_mb) | The memory size of instances used by the app (2048 or 4096) | `number` | `2048` | no |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | Key vault to get secrets from | <pre>object({<br/>    name                = string,<br/>    resource_group_name = string<br/>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Location to deploy resources to | `string` | n/a | yes |
| <a name="input_maximum_instance_count"></a> [maximum\_instance\_count](#input\_maximum\_instance\_count) | The maximum number of instances to scale the function app to | `number` | `100` | no |
| <a name="input_plan_name"></a> [plan\_name](#input\_plan\_name) | Name of the service plan to use for the function app | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to apply to all resource names | `string` | n/a | yes |
| <a name="input_remote_debugging_enabled"></a> [remote\_debugging\_enabled](#input\_remote\_debugging\_enabled) | Whether or not to enable remote debugging for the function app | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to place resources in | `string` | n/a | yes |
| <a name="input_runtime_name"></a> [runtime\_name](#input\_runtime\_name) | The name of the language worker runtime (dotnet-isolated, node, python, java, powershell) | `string` | `"dotnet-isolated"` | no |
| <a name="input_runtime_version"></a> [runtime\_version](#input\_runtime\_version) | The version of the language worker runtime | `string` | `"8.0"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the storage account to use for the function app | `string` | `null` | no |
| <a name="input_storage_authentication_type"></a> [storage\_authentication\_type](#input\_storage\_authentication\_type) | The type of authentication to use for the storage account (StorageAccountConnectionString, SystemAssignedIdentity, or UserAssignedIdentity) | `string` | `"StorageAccountConnectionString"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_registration_client_id"></a> [app\_registration\_client\_id](#output\_app\_registration\_client\_id) | The client ID of the Azure AD application registration |
| <a name="output_app_registration_object_id"></a> [app\_registration\_object\_id](#output\_app\_registration\_object\_id) | The object ID of the Azure AD application registration |
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | The default hostname of the Function App |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Function App |
| <a name="output_identity_client_id"></a> [identity\_client\_id](#output\_identity\_client\_id) | The client ID of the user assigned identity |
| <a name="output_identity_id"></a> [identity\_id](#output\_identity\_id) | The ID of the user assigned identity |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | The principal ID of the user assigned identity |
| <a name="output_name"></a> [name](#output\_name) | The name of the Function App |
| <a name="output_service_plan_id"></a> [service\_plan\_id](#output\_service\_plan\_id) | The ID of the service plan |
| <a name="output_service_plan_name"></a> [service\_plan\_name](#output\_service\_plan\_name) | The name of the service plan |
| <a name="output_service_principal_object_id"></a> [service\_principal\_object\_id](#output\_service\_principal\_object\_id) | The object ID of the service principal |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account used by the Function App |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account used by the Function App |
<!-- END_TF_DOCS -->