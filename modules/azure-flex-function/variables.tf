# Prefix Applied to All Resource Names
variable "prefix" {
  type        = string
  description = "Prefix to apply to all resource names"
}

# Name of the environment to deploy to
variable "environment" {
  type        = string
  description = "Name of the environment to deploy to"
}

# Location Where All Resources Will Be Deployed
variable "location" {
  type        = string
  description = "Location to deploy resources to"
}

# Resource Group Where All Resources Will Be Deployed
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to place resources in"
}

# Base Name for All Resources
variable "base_name" {
  type        = string
  description = "Discriminator name for all resources"
}

variable "function_name" {
  type        = string
  description = "Name of the function app to deploy"
  default     = null
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account to use for the function app"
  default     = null
}

variable "plan_name" {
  type        = string
  description = "Name of the service plan to use for the function app"
  default     = null
}

# Instrumentation Key for AppInsights instance
variable "app_insights_key" {
  type        = string
  description = "Instrumentation key for the Application Insights instance to use for logging"
  default     = null
}

# ConnectionString for AppInsights instance
variable "application_insights_connection_string" {
  type        = string
  description = "Connection string for the Application Insights instance to use for logging"
  default     = null
}

# Function environment to deploy to (Development, Staging, Production)
variable "function_environment" {
  type        = string
  description = "Prefix of the environment to deploy the function app to"
  default     = "Development"
}

# Runtime configuration
variable "runtime_name" {
  type        = string
  description = "The name of the language worker runtime (dotnet-isolated, node, python, java, powershell)"
  default     = "dotnet-isolated"

  validation {
    condition     = can(regex("^(dotnet-isolated|node|python|java|powershell)$", var.runtime_name))
    error_message = "The runtime_name must be one of: dotnet-isolated, node, python, java, powershell"
  }
}

variable "runtime_version" {
  type        = string
  description = "The version of the language worker runtime"
  default     = "8.0"
}

# Scaling configuration
variable "maximum_instance_count" {
  type        = number
  description = "The maximum number of instances to scale the function app to"
  default     = 100

  validation {
    condition     = var.maximum_instance_count >= 40 && var.maximum_instance_count <= 1000
    error_message = "The maximum_instance_count must be between 40 and 1000"
  }
}

variable "instance_memory_in_mb" {
  type        = number
  description = "The memory size of instances used by the app (2048 or 4096)"
  default     = 2048

  validation {
    condition     = contains([2048, 4096], var.instance_memory_in_mb)
    error_message = "The instance_memory_in_mb must be either 2048 or 4096"
  }
}

# Storage authentication
variable "storage_authentication_type" {
  type        = string
  description = "The type of authentication to use for the storage account (StorageAccountConnectionString, SystemAssignedIdentity, or UserAssignedIdentity)"
  default     = "StorageAccountConnectionString"

  validation {
    condition     = can(regex("^(StorageAccountConnectionString|SystemAssignedIdentity|UserAssignedIdentity)$", var.storage_authentication_type))
    error_message = "The storage_authentication_type must be one of: StorageAccountConnectionString, SystemAssignedIdentity, UserAssignedIdentity"
  }
}

# Map of application settings to send to the function app
variable "app_settings" {
  type        = map(string)
  description = "Key value pairs of application settings to apply to the function application"
  default     = {}
}

variable "app_roles" {
  type = list(object({
    id : string,
    value : string,
    display_name : string,
    description : string
  }))
  description = "List of Application scoped roles to support"
  default     = []
}

variable "key_vault" {
  description = "Key vault to get secrets from"
  type = object({
    name                = string,
    resource_group_name = string
  })
  default = null
}

variable "deploy_using_slots" {
  description = "Whether or not to deploy the function app using deployment slots. If true, a staging slot will be created."
  type        = bool
  default     = false
}

variable "remote_debugging_enabled" {
  type        = bool
  description = "Whether or not to enable remote debugging for the function app"
  default     = false
}

