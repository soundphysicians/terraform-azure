<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurecaf"></a> [azurecaf](#requirement\_azurecaf) | >= 1.2.11 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider\_azurecaf) | >= 1.2.11 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.1.0 |
| <a name="provider_azurerm.audit"></a> [azurerm.audit](#provider\_azurerm.audit) | >= 3.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurecaf_name.server](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/name) | resource |
| [azurerm_mssql_database.db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_database_extended_auditing_policy.db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database_extended_auditing_policy) | resource |
| [azurerm_mssql_firewall_rule.sql_firewall_allow_azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) | resource |
| [azurerm_mssql_firewall_rule.sql_firewall_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) | resource |
| [azurerm_mssql_server.server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_mssql_server_extended_auditing_policy.server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_storage_account.audit](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | The username for the SQL sa administrator account | `string` | `"sqladmin"` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of your application | `string` | `""` | no |
| <a name="input_auditing_storage_account"></a> [auditing\_storage\_account](#input\_auditing\_storage\_account) | Storage account destination for database audit logs. Only applies in prd environment. | <pre>object({<br>    subscription_id      = string,<br>    storage_account_name = string,<br>    resource_group_name  = string<br>  })</pre> | n/a | yes |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | Base Name for All Resources Given: prefix:         sbs environment:    tst base\_name:      blah Result: sql server name:      sbs-tst-sql-blah sql database name:    sbs-tst-sqldb-blah | `any` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment to deploy to | `string` | `"tdd"` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Exceptions to allow access to certain IP addresses | <pre>list(object({<br>    name             = string,<br>    start_ip_address = string,<br>    end_ip_address   = string<br>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Location Where All Resources Will Be Deployed | `any` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix Applied to  All Resource Names | `any` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group Where All Resources Will Be Deployed | `any` | n/a | yes |
| <a name="input_sql_ad_admin_object_id"></a> [sql\_ad\_admin\_object\_id](#input\_sql\_ad\_admin\_object\_id) | Object ID of database AD administrator | `any` | n/a | yes |
| <a name="input_sql_ad_admin_username"></a> [sql\_ad\_admin\_username](#input\_sql\_ad\_admin\_username) | Username (email address) of the database AD administrator | `any` | n/a | yes |
| <a name="input_sql_perf_level"></a> [sql\_perf\_level](#input\_sql\_perf\_level) | Database SKU | `string` | `"S0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_password"></a> [database\_password](#output\_database\_password) | The Azure SQL server password. |
| <a name="output_database_url"></a> [database\_url](#output\_database\_url) | The Azure SQL server URL. |
| <a name="output_database_username"></a> [database\_username](#output\_database\_username) | The Azure SQL server user name. |
| <a name="output_sql_database_name"></a> [sql\_database\_name](#output\_sql\_database\_name) | The name of the database on the Azure SQL server |
| <a name="output_sql_fully_qualified_domain_name"></a> [sql\_fully\_qualified\_domain\_name](#output\_sql\_fully\_qualified\_domain\_name) | The fully qualified domain name of the SQL server |
<!-- END_TF_DOCS -->