variable "namespace_name" {
  description = "The name of the Azure EventHub Namespace to create the EventHub in"
  type        = string
}

variable "storage_account_id" {
  description = "The ID of the storage account used for capturing events"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account used for capturing events"
  type        = string
}

variable "name" {
  description = "The name of the Event Hub to create"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which resources will be created"
  type        = string
}

variable "partition_count" {
  description = "The number of partitions to create in the Event Hub"
  type        = number
  default     = 4
}

variable "message_retention" {
  description = "The number of days to retain messages in the Event Hub"
  type        = number
  default     = 7
}

variable "producers" {
  description = "List of producers to give access to the Event Hub"
  type        = list(object({ name = string }))
}

variable "consumer_groups" {
  description = "List of event consumer groups to give access to the Event Hub"
  type        = list(object({ name = string, description = string }))
}
