<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_mssql"></a> [mssql](#requirement\_mssql) | ~> 0.2.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mssql"></a> [mssql](#provider\_mssql) | ~> 0.2.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mssql_user.appDb](https://registry.terraform.io/providers/betr-io/mssql/latest/docs/resources/user) | resource |
| [mssql_user.master](https://registry.terraform.io/providers/betr-io/mssql/latest/docs/resources/user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name of the SQL database | `string` | n/a | yes |
| <a name="input_db_user"></a> [db\_user](#input\_db\_user) | The user to grant access to the database | <pre>object({<br>    username     = string,<br>    object_id    = string,<br>    roles        = optional(list(string)),<br>    master_roles = optional(list(string))<br>  })</pre> | <pre>{<br>  "master_roles": [],<br>  "object_id": null,<br>  "roles": [],<br>  "username": null<br>}</pre> | no |
| <a name="input_sql_server_admin_password"></a> [sql\_server\_admin\_password](#input\_sql\_server\_admin\_password) | Password for the sql administrator login | `string` | n/a | yes |
| <a name="input_sql_server_admin_username"></a> [sql\_server\_admin\_username](#input\_sql\_server\_admin\_username) | Name of the sql administrator login | `string` | n/a | yes |
| <a name="input_sql_server_fqdn"></a> [sql\_server\_fqdn](#input\_sql\_server\_fqdn) | Fully qualified domain name of the SQL Server instance to connect to | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_roles"></a> [application\_roles](#output\_application\_roles) | Roles assigned the user in the application database. |
| <a name="output_master_roles"></a> [master\_roles](#output\_master\_roles) | Roles assigned the user in the master database. |
| <a name="output_username"></a> [username](#output\_username) | The Azure SQL user name. |
<!-- END_TF_DOCS -->