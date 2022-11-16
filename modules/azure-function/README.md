<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurecaf"></a> [azurecaf](#requirement\_azurecaf) | >= 1.2.11 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurecaf"></a> [azurecaf](#provider\_azurecaf) | >= 1.2.11 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_service_principal.app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurecaf_name.fn](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.plan](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurecaf_name.storage](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurerm_app_service_plan.plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan) | resource |
| [azurerm_function_app.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app) | resource |
| [azurerm_function_app_slot.slot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app_slot) | resource |
| [azurerm_key_vault_access_policy.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.slot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_storage_account.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_insights_key"></a> [app\_insights\_key](#input\_app\_insights\_key) | Instrumentation Key for AppInsights instance | `any` | n/a | yes |
| <a name="input_app_roles"></a> [app\_roles](#input\_app\_roles) | List of Application scoped roles to support | <pre>list(object({<br>    id : string,<br>    value : string,<br>    display_name : string,<br>    description : string<br>  }))</pre> | n/a | yes |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Map of application settings to send to the function app | `any` | n/a | yes |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | Base Name for All Resources Given: prefix:         sbs environment:    tst base\_name:      myfunc Result: function name:      sbs-tst-fn-myfunc storage account:    sbststsamyfunc service plan:       sbs-tst-asplan-myfunc | `any` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment to deploy to | `any` | n/a | yes |
| <a name="input_function_environment"></a> [function\_environment](#input\_function\_environment) | Function environment to deploy to (Development, Staging, Production) | `any` | n/a | yes |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | Object Id of the key vault to get secrets from | <pre>object({<br>    name                = string,<br>    resource_group_name = string<br>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location Where All Resources Will Be Deployed | `any` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix Applied to  All Resource Names | `any` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group Where All Resources Will Be Deployed | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->