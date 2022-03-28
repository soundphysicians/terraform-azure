# Prefix Applied to  All Resource Names
variable "prefix" {}

# Name of the environment to deploy to
variable "environment" {
  description = "The name of the environment to deploy to"
  validation {
    condition     = contains(["tdd", "dev", "tst", "prd", "stage"], var.environment)
    error_message = "Valid values for var: environment are (tdd, dev, tst, prd, stage)"
  }

  default = "tdd"
}

# Location Where All Resources Will Be Deployed
variable "location" {}

# Resource Group Where All Resources Will Be Deployed
variable "resource_group_name" {}

# Base Name for All Resources 
# Given: 
#   prefix:         sbs
#   environment:    tst
#   base_name:      blah
# Result:
#   sql server name:      sbs-tst-sql-blah
#   sql database name:    sbs-tst-sqldb-blah
variable "base_name" {}

variable "application_name" {
  type        = string
  description = "The name of your application"
  default     = ""
}

# Database SKU
variable sql_perf_level {
  default = "S0"
}

variable administrator_login {
  type        = string
  description = "The username for the SQL sa administrator account"
  default     = "sqladmin"
}

variable sql_ad_admin_username {
  description = "Username (email address) of the database AD administrator"
}

variable sql_ad_admin_object_id {
  description = "Object ID of database AD administrator"

  validation {
    condition = can(regex(
      "^[0-9a-fA-F]{8}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{12}$",
      var.sql_ad_admin_object_id
      )
    )
    error_message = "Expected sql_ad_admin_object_id to be a valid UUID."
  }
}

# Centralized logging and auditing for production SQL environments
variable auditing_storage_account {
  description = "Storage account destination for database audit logs. Only applies in prd environment."
  type = object({
    subscription_id      = string,
    storage_account_name = string,
    resource_group_name  = string
  })

  validation {
    condition = (
      length(var.auditing_storage_account.subscription_id) > 10
    )
    error_message = "Auditing storage account subscription must be provided and greater than 10 characters in length."
  }

  validation {
    condition = (
      length(var.auditing_storage_account.storage_account_name) > 3 &&
      length(var.auditing_storage_account.storage_account_name) < 24
    )
    error_message = "Auditing storage account name must be 3-24 characters in length."
  }

  validation {
    condition = (
      length(var.auditing_storage_account.resource_group_name) > 3
    )
    error_message = "Auditing storage account resource group must be provided."
  }
}

variable firewall_rules {
  description = "Exceptions to allow access to certain IP addresses"
  type = list(object({
    name             = string,
    start_ip_address = string,
    end_ip_address   = string
  }))

  default = []
}
