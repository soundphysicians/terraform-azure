<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_authorization_rule.consumers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_authorization_rule) | resource |
| [azurerm_eventhub_authorization_rule.producers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_authorization_rule) | resource |
| [azurerm_eventhub_consumer_group.consumers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_storage_container.capturestorage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_account.capturestorage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_consumer_groups"></a> [consumer\_groups](#input\_consumer\_groups) | List of event consumer groups to give access to the Event Hub | `list(object({ name = string, description = string }))` | n/a | yes |
| <a name="input_message_retention"></a> [message\_retention](#input\_message\_retention) | The number of days to retain messages in the Event Hub | `number` | `7` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Event Hub to create | `string` | n/a | yes |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | The name of the Azure EventHub Namespace to create the EventHub in | `string` | n/a | yes |
| <a name="input_partition_count"></a> [partition\_count](#input\_partition\_count) | The number of partitions to create in the Event Hub | `number` | `4` | no |
| <a name="input_producers"></a> [producers](#input\_producers) | List of producers to give access to the Event Hub | `list(object({ name = string }))` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the Resource Group in which resources will be created | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the storage account used for capturing events | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | n/a |
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | n/a |
| <a name="output_login_server"></a> [login\_server](#output\_login\_server) | n/a |
| <a name="output_registry_name"></a> [registry\_name](#output\_registry\_name) | n/a |
<!-- END_TF_DOCS -->