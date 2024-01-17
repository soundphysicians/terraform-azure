provider "azurerm" {
  features {}
}

variables {
    namespace_name = "snd-mie-tdd-eh"
    storage_account_name = "sndmietddehsa"
    name = "mie-tdd-eh-salesforce-provideragreementexecuted"
    resource_group_name = "mie-tdd-rg"
    partition_count = 4
    message_retention = 7
    producers = [
        {
            name = "test-producer"
        }
    ]
    consumer_groups = [
        {
            name = "test-consumer-group-1"
            description = "Test consumer group 1"
        },
                {
            name = "test-consumer-group-2"
            description = "Test consumer group 2"
        }
    ]
}

run "should_create_authorization_rule_for_producers" {
    command= plan 

    variables {

    }

    assert {
        condition = contains(keys(azurerm_eventhub_authorization_rule.producers), var.producers[0].name)
        error_message = "Should create authorization rule for consumers"
    }
}

run "should_create_authorization_rule_for_consumers" {
    command= plan 

    variables {

    }

    assert {
        condition = contains(keys(azurerm_eventhub_authorization_rule.consumers), var.consumer_groups[0].name)
        error_message = "Should create authorization rule for consumers"
    }

    assert {
        condition = contains(keys(azurerm_eventhub_authorization_rule.consumers), var.consumer_groups[1].name)
        error_message = "Should create authorization rule for consumers"
    }
}

run "should_create_consumer_groups_for_consumers" {
    command= plan 

    variables {

    }

    assert {
        condition = contains(keys(azurerm_eventhub_consumer_group.consumers), var.consumer_groups[0].name)
        error_message = "Should create authorization rule for consumers"
    }

    assert {
        condition = contains(keys(azurerm_eventhub_consumer_group.consumers), var.consumer_groups[1].name)
        error_message = "Should create authorization rule for consumers"
    }
}

run "should_output_consumer_connection_strings" {
    command= plan 

    variables {

    }

    assert {
        condition = contains(keys(output.consumer_connection_strings), var.consumer_groups[0].name)
        error_message = "Should output connection string for consumer 1"
    }

    assert {
        condition = contains(keys(output.consumer_connection_strings), var.consumer_groups[1].name)
        error_message = "Should output connection string for consumer 2"
    }
}
