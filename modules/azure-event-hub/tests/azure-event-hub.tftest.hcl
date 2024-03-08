provider "azurerm" {
  features {}
}

variables {
  namespace_name       = "snd-mie-tdd-eh"
  storage_account_name = "sndmietddehsa"
  name                 = "mie-tdd-eh-salesforce-provideragreementexecuted"
  resource_group_name  = "mie-tdd-rg"
  partition_count      = 4
  message_retention    = 7
  producers = [
    {
      name = "test-producer"
    }
  ]
  consumer_groups = [
    {
      name        = "test-consumer-group-1"
      description = "Test consumer group 1"
    },
    {
      name        = "test-consumer-group-2"
      description = "Test consumer group 2"
    }
  ]
}

run "should_create_authorization_rule_for_producers" {
  command = plan

  variables {

  }

  assert {
    condition     = contains(keys(azurerm_eventhub_authorization_rule.producers), var.producers[0].name)
    error_message = "Should create authorization rule for consumers"
  }
}

run "should_output_producer_connection_strings" {
  command = plan

  variables {
    producers = [
      {
        name = "test-producer-1"
      },
      {
        name = "test-producer-2"
      }
    ]

  }

  assert {
    condition     = contains(keys(output.producer_connection_strings), var.producers[0].name)
    error_message = "Should output connection string for producer 1"
  }

  assert {
    condition     = contains(keys(output.producer_connection_strings), var.producers[1].name)
    error_message = "Should output connection string for producer 2"
  }
}

run "should_create_authorization_rule_for_consumers" {
  command = plan

  variables {

  }

  assert {
    condition     = contains(keys(azurerm_eventhub_authorization_rule.consumers), var.consumer_groups[0].name)
    error_message = "Should create authorization rule for consumers"
  }

  assert {
    condition     = contains(keys(azurerm_eventhub_authorization_rule.consumers), var.consumer_groups[1].name)
    error_message = "Should create authorization rule for consumers"
  }
}

run "should_create_consumer_groups_for_consumers" {
  command = plan

  variables {

  }

  assert {
    condition     = contains(keys(azurerm_eventhub_consumer_group.consumers), var.consumer_groups[0].name)
    error_message = "Should create authorization rule for consumers"
  }

  assert {
    condition     = contains(keys(azurerm_eventhub_consumer_group.consumers), var.consumer_groups[1].name)
    error_message = "Should create authorization rule for consumers"
  }
}

run "should_output_consumer_connection_strings" {
  command = plan

  variables {

  }

  assert {
    condition     = contains(keys(output.consumer_connection_strings), var.consumer_groups[0].name)
    error_message = "Should output connection string for consumer 1"
  }

  assert {
    condition     = contains(keys(output.consumer_connection_strings), var.consumer_groups[1].name)
    error_message = "Should output connection string for consumer 2"
  }
}

run "should_use_default_capture_archive_name_format" {
  command = plan

  variables {

  }

  assert {
    condition     = azurerm_eventhub.hub.capture_description[0].destination[0].archive_name_format == "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
    error_message = "Should use default capture archive name format."
  }
}

run "should_use_specified_capture_archive_name_format" {
  command = plan

  variables {
    capture_archive_name_format = "{Namespace}/{EventHub}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}/{PartitionId}"
  }

  assert {
    condition     = azurerm_eventhub.hub.capture_description[0].destination[0].archive_name_format == "{Namespace}/{EventHub}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}/{PartitionId}"
    error_message = "Should use specified capture archive name format."
  }
}
