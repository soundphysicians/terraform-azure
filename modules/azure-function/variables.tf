# Prefix Applied to  All Resource Names
variable "prefix" {}

# Name of the environment to deploy to
variable "environment" {}

# Location Where All Resources Will Be Deployed
variable "location" {}

# Resource Group Where All Resources Will Be Deployed
variable "resource_group_name" {}

# Base Name for All Resources 
# Given: 
#   prefix:         sbs
#   environment:    tst
#   base_name:      myfunc
# Result:
#   function name:      sbs-tst-fn-myfunc
#   storage account:    sbststsamyfunc
#   service plan:       sbs-tst-asplan-myfunc
variable "base_name" {}

# Instrumentation Key for AppInsights instance
variable "app_insights_key" {}

# Function environment to deploy to (Development, Staging, Production)
variable "function_environment" {}

# Map of application settings to send to the function app
variable app_settings {}

variable app_roles {
  type = list(object({
    id : string,
    value : string,
    display_name : string,
    description : string
  }))
  description = "List of Application scoped roles to support"
}

variable "key_vault" {
  description = "Object Id of the key vault to get secrets from"
  type = object({
    name                = string,
    resource_group_name = string
  })
}
