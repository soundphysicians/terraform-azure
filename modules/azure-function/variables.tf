# Prefix Applied to  All Resource Names
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
# Given: 
#   prefix:         sbs
#   environment:    tst
#   base_name:      myfunc
# Result:
#   function name:      sbs-tst-fn-myfunc
#   storage account:    sbststsamyfunc
#   service plan:       sbs-tst-asplan-myfunc
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
  default     = ""
}

# Function environment to deploy to (Development, Staging, Production)
variable "function_environment" {
  type        = string
  description = "Prefix of the environment to deploy the function app to"
  default     = "Development"
}

variable "dotnet_version" {
  type        = string
  description = "Version of the .NET runtime to use for the function app"
  default     = "v6.0"

  validation {
    condition     = can(regex("^(v\\d+\\.\\d+)$", var.dotnet_version))
    error_message = "Dotnet version must be in the format 'vX.X'"
  }

  validation {
    condition     = contains(["v4.0", "v6.0", "v7.0", "v8.0"], var.dotnet_version)
    error_message = "Dotnet version must one of the following values (v4.0, v6.0, v7.0 or v8.0)"
  }
}

variable "use_dotnet_isolated_runtime" {
  description = "Whether or not to use the .NET isolated runtime for the function app"
  type        = bool
  default     = false
}

variable "app_scale_limit" {
  type        = number
  description = "Maximum number of instances to scale the function app to"
  default     = 1
}

variable "remote_debugging_enabled" {
  type        = bool
  description = "Whether or not to enable remote debugging for the function app"
  default     = false
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
  description = "Object Id of the key vault to get secrets from"
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