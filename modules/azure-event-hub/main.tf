terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Storage account container for capturing events
# -----------------------------------------------------------------------------
data "azurerm_storage_account" "capturestorage" {
  name = var.storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_storage_container" "capturestorage" {
  name                  = var.name
  storage_account_name  = data.azurerm_storage_account.capturestorage.name
  container_access_type = "private" # default: private
}

# -----------------------------------------------------------------------------
# Event hub for publishing of events
# -----------------------------------------------------------------------------
resource "azurerm_eventhub" "hub" {
  name                = var.name
  namespace_name      = var.namespace_name
  resource_group_name = var.resource_group_name
  partition_count     = var.partition_count   # default: 4
  message_retention   = var.message_retention # default: 1
  capture_description {
    enabled             = true
    encoding            = "AvroDeflate"
    interval_in_seconds = 300       # default: 300
    size_limit_in_bytes = 314572800 # default: 314572800
    skip_empty_archives = true      # default: false
    destination {
      name                = "EventHubArchive.AzureBlockBlob"
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
      blob_container_name = azurerm_storage_container.capturestorage.name
      storage_account_id  = data.azurerm_storage_account.capturestorage.id
    }
  }
}

# -----------------------------------------------------------------------------
# Authorization rule to allow producers to publish events to the hub
# -----------------------------------------------------------------------------
resource "azurerm_eventhub_authorization_rule" "producers" {
  # convert the list of objects into a map with the key being the name of the producer
  for_each = { for p in var.producers : p.name => p }

  name                = each.key
  namespace_name      = azurerm_eventhub.hub.namespace_name
  eventhub_name       = azurerm_eventhub.hub.name
  resource_group_name = azurerm_eventhub.hub.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

# -----------------------------------------------------------------------------
# Authorization rule to allow subscribers access to listen to events on the hub
# -----------------------------------------------------------------------------
resource "azurerm_eventhub_authorization_rule" "consumers" {
  # convert the list of objects into a map with the key being the name of the consumer group
  for_each = { for cg in var.consumer_groups : cg.name => cg }

  name                = each.value.name
  namespace_name      = azurerm_eventhub.hub.namespace_name
  eventhub_name       = azurerm_eventhub.hub.name
  resource_group_name = azurerm_eventhub.hub.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

# -----------------------------------------------------------------------------
# Set up consumer groups for the event hub
# -----------------------------------------------------------------------------
resource "azurerm_eventhub_consumer_group" "consumers" {
  # convert the list of objects into a map with the key being the name of the consumer group
  for_each = { for cg in var.consumer_groups : cg.name => cg }

  name                = each.value.name
  namespace_name      = azurerm_eventhub.hub.namespace_name
  eventhub_name       = azurerm_eventhub.hub.name
  resource_group_name = azurerm_eventhub.hub.resource_group_name
  user_metadata       = each.value.description
}
