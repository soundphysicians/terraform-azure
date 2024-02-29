variable "project" {
  description = "Name of the project"
  type        = string
  default     = "sbs"
}

variable "name" {
  description = "Name of the container instance"
  type        = string
}

variable "identity" {
  description = "The identity of the container instance"
  type        = string
}

variable "environment" {
  description = "Environment into which the resources will be deployed"
  type        = string
}

variable "resource_group" {
  description = "Resource Group into which the resources will be deployed"
  type = object({
    name     = string,
    location = string
  })
}

variable "key_vault" {
  description = "Object Id of the key vault to get secrets from"
  type = object({
    name                = string,
    resource_group_name = string
  })
}

variable "log_analytics_workspace" {
  description = "The destination Log Analytics Workspace"
  type = object({
    name                = string,
    resource_group_name = string
  })
}

variable "app_insights_telemetry_key" {
  description = "Application Insights Telemetry Key"
  type        = string
}

variable "container_image" {
  description = "Container Image Name Info"
  type = object({
    name    = string,
    version = string
  })
}

variable "database_connection_string_name" {
  description = "Name of the connection string secret in the Azure Key Vault"
  type        = string
}

variable "service_bus_connection_string_name" {
  description = "Name of the connection string secret in the Azure Key Vault"
  type        = string
}

variable "container_registry" {
  description = "The container registry to pull images from"
  type = object({
    login_server = string,
    username     = string,
    password     = string
  })
}

variable "vnet_integration_enabled" {
  description = "Is private networking enabled for this container instance"
  type        = bool
  default     = false
  nullable    = false
}

variable "subnet_id" {
  description = "The subnet to associate the container instance with. Can be null to use public IP addresses"
  type        = string
  default     = null
  nullable    = true
}

variable "secure_environment_variables" {
  description = "Key-value collection of environment variables to be provided to the container securely"
  type        = map(any)
  default     = {}
  nullable    = false
}

variable "environment_variables" {
  description = "Key-value collection of environment variables to be provided to the container"
  type        = map(any)
  default     = {}
  nullable    = false
}
