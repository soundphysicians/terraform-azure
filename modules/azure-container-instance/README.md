<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_group.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) | resource |
| [azurerm_key_vault_access_policy.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_network_profile.network_profile](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_profile) | resource |
| [azurerm_user_assigned_identity.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_insights_telemetry_key"></a> [app\_insights\_telemetry\_key](#input\_app\_insights\_telemetry\_key) | Application Insights Telemetry Key | `string` | n/a | yes |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Container Image Name Info | <pre>object({<br>    name    = string,<br>    version = string<br>  })</pre> | n/a | yes |
| <a name="input_container_registry"></a> [container\_registry](#input\_container\_registry) | The container registry to pull images from | <pre>object({<br>    login_server = string,<br>    username     = string,<br>    password     = string<br>  })</pre> | n/a | yes |
| <a name="input_database_connection_string_name"></a> [database\_connection\_string\_name](#input\_database\_connection\_string\_name) | Name of the connection string secret in the Azure Key Vault | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment into which the resources will be deployed | `string` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Key-value collection of environment variables to be provided to the container | `map(any)` | `{}` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | The identity of the container instance | `string` | n/a | yes |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | Object Id of the key vault to get secrets from | <pre>object({<br>    name                = string,<br>    resource_group_name = string<br>  })</pre> | n/a | yes |
| <a name="input_log_analytics_workspace"></a> [log\_analytics\_workspace](#input\_log\_analytics\_workspace) | The destination Log Analytics Workspace | <pre>object({<br>    name                = string,<br>    resource_group_name = string<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the container instance | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Name of the project | `string` | `"sbs"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource Group into which the resources will be deployed | <pre>object({<br>    name     = string,<br>    location = string<br>  })</pre> | n/a | yes |
| <a name="input_secure_environment_variables"></a> [secure\_environment\_variables](#input\_secure\_environment\_variables) | Key-value collection of environment variables to be provided to the container securely | `map(any)` | `{}` | no |
| <a name="input_service_bus_connection_string_name"></a> [service\_bus\_connection\_string\_name](#input\_service\_bus\_connection\_string\_name) | Name of the connection string secret in the Azure Key Vault | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet to associate the container instance with. Can be null to use public IP addresses | `string` | `null` | no |
| <a name="input_vnet_integration_enabled"></a> [vnet\_integration\_enabled](#input\_vnet\_integration\_enabled) | Is private networking enabled for this container instance | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_identity_id"></a> [identity\_id](#output\_identity\_id) | The ID of the identity that the container runs under |
| <a name="output_identity_name"></a> [identity\_name](#output\_identity\_name) | The name of the identity that the container runs under |
<!-- END_TF_DOCS -->