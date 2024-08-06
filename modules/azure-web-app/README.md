<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.api-role-assignments](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_app_role_assignment.test-automation](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_application.webapp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.webapp_1](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_application_pre_authorized.azure-cli](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_pre_authorized) | resource |
| [azuread_service_principal.webapp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_app_service.webapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service) | resource |
| [azurerm_app_service_plan.webapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan) | resource |
| [azurerm_key_vault_access_policy.webapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_user_assigned_identity.webapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_uuid.webapp](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_service_principal.test_automation](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.mercury](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_resource_group.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of the web app. Overrides the default naming convention | `string` | `null` | no |
| <a name="input_app_role_assignments"></a> [app\_role\_assignments](#input\_app\_role\_assignments) | Set of fixed users and roles for the application | <pre>list(object({<br>    application_object_id = string,      # Azure AD Client ID for the client application <br>    role_ids              = list(string) # list of roles that the application has access to<br>  }))</pre> | `[]` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Key value pairs of settings to pass as application settings | `map(string)` | `{}` | no |
| <a name="input_connection_strings"></a> [connection\_strings](#input\_connection\_strings) | Collection of connection strings used by the application | <pre>list(object({<br>    name  = string<br>    type  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_custom_domain_name"></a> [custom\_domain\_name](#input\_custom\_domain\_name) | Root url for the production environment, if a static name is required | `string` | `null` | no |
| <a name="input_devtest_port"></a> [devtest\_port](#input\_devtest\_port) | Port number to use for local development to support authentication redirects | `number` | `null` | no |
| <a name="input_dotnet_framework_version"></a> [dotnet\_framework\_version](#input\_dotnet\_framework\_version) | Version of the dotnet framework to run | `string` | `"v6.0"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | (Optional) The environment short name to use for the deployed resources.<br><br>  Options:<br>  - tdd<br>  - dev<br>  - tst<br>  - uat<br>  - prd<br><br>  Default: tdd | `string` | `"tdd"` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Path to the health check endpoint inside the application. ex. /health | `string` | `null` | no |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | Key vault to use for secrets | <pre>object({<br>    name                = string,<br>    resource_group_name = string<br>  })</pre> | `null` | no |
| <a name="input_plan_name"></a> [plan\_name](#input\_plan\_name) | The name of the web app service plan. Overrides the default naming convention | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix which becomes the first segment of all resource names | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The name of the project, used for resource tagging | `string` | n/a | yes |
| <a name="input_remote_debugging_enabled"></a> [remote\_debugging\_enabled](#input\_remote\_debugging\_enabled) | Enable remote debugging for the web app | `bool` | `false` | no |
| <a name="input_required_graph_access"></a> [required\_graph\_access](#input\_required\_graph\_access) | Set of graph resources the web app requires | <pre>list(object({<br>    id   = string<br>    type = string<br>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to place resources in | `string` | n/a | yes |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | The suffix which becomes the last segment of all resource names | `string` | n/a | yes |
| <a name="input_supported_app_roles"></a> [supported\_app\_roles](#input\_supported\_app\_roles) | Set of roles that the application supports | <pre>list(object({<br>    id           = string<br>    description  = string<br>    display_name = string<br>    enabled      = bool<br>    value        = string<br>  }))</pre> | `[]` | no |
| <a name="input_test_automation_application_id"></a> [test\_automation\_application\_id](#input\_test\_automation\_application\_id) | Application used for test automation | `string` | `null` | no |
| <a name="input_web_app_plan_type"></a> [web\_app\_plan\_type](#input\_web\_app\_plan\_type) | Plan type (scale level) for the application | <pre>object({<br>    tier = string<br>    size = string<br>  })</pre> | <pre>{<br>  "size": "B1",<br>  "tier": "Basic"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_webapp_client_id"></a> [webapp\_client\_id](#output\_webapp\_client\_id) | The client ID of the Azure AD Application |
| <a name="output_webapp_client_secret"></a> [webapp\_client\_secret](#output\_webapp\_client\_secret) | The client secret of the Azure AD Application |
| <a name="output_webapp_managed_identity_id"></a> [webapp\_managed\_identity\_id](#output\_webapp\_managed\_identity\_id) | The ID of the User Assigned Identity |
<!-- END_TF_DOCS -->