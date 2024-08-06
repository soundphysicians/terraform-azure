<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_mssql"></a> [mssql](#requirement\_mssql) | >= 0.2.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mssql"></a> [mssql](#provider\_mssql) | >= 0.2.4 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mssql_login.login](https://registry.terraform.io/providers/betr-io/mssql/latest/docs/resources/login) | resource |
| [mssql_user.user](https://registry.terraform.io/providers/betr-io/mssql/latest/docs/resources/user) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the database to assign to the user | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | Password for the SQL user | `string` | `null` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | Array of role names to assign to the user | `list(string)` | `[]` | no |
| <a name="input_sql_admin_password"></a> [sql\_admin\_password](#input\_sql\_admin\_password) | Password of the sql administrator account | `string` | n/a | yes |
| <a name="input_sql_admin_username"></a> [sql\_admin\_username](#input\_sql\_admin\_username) | Username of the sql administrator account | `string` | n/a | yes |
| <a name="input_sql_fully_qualified_domain_name"></a> [sql\_fully\_qualified\_domain\_name](#input\_sql\_fully\_qualified\_domain\_name) | Fully qualified domain name of the SQL server | `any` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | Username for the SQL user | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_password"></a> [password](#output\_password) | The Azure SQL user password. |
<!-- END_TF_DOCS -->