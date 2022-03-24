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
#   base_name:      blah
# Result:
#   sql server name:      sbs-tst-sqlserver-blah
#   sql database name:    sbs-tst-sqldb-blah
variable "base_name" {}

# Database SKU
variable sql_perf_level {
  default = "S0"
}

# KeyVault secret for the sql admin username
variable sql_admin_username_secret {
  type = object({
    value = string
  })
}

# KeyVault secret for the sql admin password
variable sql_admin_password_secret {
  type = object({
    value = string
  })
}

variable sql_ad_admin_username {
  description = "Username (email address) of the database AD administrator"
}

variable sql_ad_admin_object_id {
  description = "Object ID of database AD administrator"
}

# Centralized logging and auditing for production SQL environments
variable auditing_storage_account {
  description = "Storage account destination for database audit logs. Only applies in prd environment"
  type = object({
    subscription_id      = string,
    storage_account_name = string,
    resource_group_name  = string
  })

  validation {
    condition = (
      length(var.auditing_storage_account.subscription_id) > 10
    )
    error_message = "Auditing storage account subscription must be provided and greater than 10 characters in length"
  }

  validation {
    condition = (
      length(var.auditing_storage_account.storage_account_name) > 3 &&
      length(var.auditing_storage_account.storage_account_name) < 24
    )
    error_message = "Auditing storage account name must be 3-24 characters in length"
  }

  validation {
    condition = (
      length(var.auditing_storage_account.resource_group_name) > 3
    )
    error_message = "Auditing storage account resource group must be provided"
  }
}
