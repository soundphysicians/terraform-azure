<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | ../azure-storage-account | n/a |

## Resources

| Name | Type |
|------|------|
| [azuread_application.app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_service_principal.app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_key_vault_access_policy.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.slot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_linux_function_app.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_linux_function_app_slot.slot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app_slot) | resource |
| [azurerm_service_plan.plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_user_assigned_identity.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_insights_key"></a> [app\_insights\_key](#input\_app\_insights\_key) | Instrumentation key for the Application Insights instance to use for logging | `string` | `null` | no |
| <a name="input_app_roles"></a> [app\_roles](#input\_app\_roles) | List of Application scoped roles to support | <pre>list(object({<br>    id : string,<br>    value : string,<br>    display_name : string,<br>    description : string<br>  }))</pre> | `[]` | no |
| <a name="input_app_scale_limit"></a> [app\_scale\_limit](#input\_app\_scale\_limit) | Maximum number of instances to scale the function app to | `number` | `1` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Key value pairs of application settings to apply to the function application | `map(string)` | `{}` | no |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | Discriminator name for all resources | `string` | n/a | yes |
| <a name="input_deploy_using_slots"></a> [deploy\_using\_slots](#input\_deploy\_using\_slots) | Whether or not to deploy the function app using deployment slots. If true, a staging slot will be created. | `bool` | `false` | no |
| <a name="input_dotnet_version"></a> [dotnet\_version](#input\_dotnet\_version) | Version of the .NET runtime to use for the function app | `string` | `"6.0"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment to deploy to | `string` | n/a | yes |
| <a name="input_function_environment"></a> [function\_environment](#input\_function\_environment) | Prefix of the environment to deploy the function app to | `string` | `"Development"` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the function app to deploy | `string` | `null` | no |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | Object Id of the key vault to get secrets from | <pre>object({<br>    name                = string,<br>    resource_group_name = string<br>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Location to deploy resources to | `string` | n/a | yes |
| <a name="input_plan_name"></a> [plan\_name](#input\_plan\_name) | Name of the service plan to use for the function app | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to apply to all resource names | `string` | n/a | yes |
| <a name="input_remote_debugging_enabled"></a> [remote\_debugging\_enabled](#input\_remote\_debugging\_enabled) | Whether or not to enable remote debugging for the function app | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to place resources in | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the storage account to use for the function app | `string` | `null` | no |
| <a name="input_use_dotnet_isolated_runtime"></a> [use\_dotnet\_isolated\_runtime](#input\_use\_dotnet\_isolated\_runtime) | Whether or not to use the .NET isolated runtime for the function app | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->