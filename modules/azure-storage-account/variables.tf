# Location Where All Resources Will Be Deployed
variable "location" {
  type        = string
  description = "Location to deploy resources to"

  validation {
    condition     = length(var.location) > 0
    error_message = "Location must be provided."
  }
}

# Resource Group Where All Resources Will Be Deployed
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to place resources in"

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name must be provided."
  }
}

variable "name" {
  type = object({
    prefix        = string,
    environment   = string,
    base_name     = string,
    name_override = string
  })

  description = "Values used in naming of the storage account. If name_override is provided, it will be used instead of the derived name. If name_override is not provided, the derived name will be used which is formatted as {prefix}{environment}sa{base_name}."

  validation {
    condition     = length(try(var.name.name_override, null)) == 0 ? length(var.name.prefix) > 0 : true
    error_message = "Prefix must be provided if name_override is not provided."
  }

  validation {
    condition     = length(try(var.name.name_override, null)) == 0 ? length(var.name.environment) > 0 : true
    error_message = "Environment must be provided if name_override is not provided."
  }

  validation {
    condition     = length(try(var.name.name_override, null)) == 0 ? contains(["tdd", "dev", "qa", "tst", "uat", "stage", "prd"], var.name.environment) : true
    error_message = "Environment must be provided if name_override is not provided."
  }

  validation {
    condition     = length(try(var.name.name_override, null)) == 0 ? length(var.name.base_name) > 0 : true
    error_message = "Base name must be provided if name_override is not provided."
  }

  validation {
    condition     = length(try(var.name.name_override, null)) == 0 ? length(var.name.prefix) > 0 : true
    error_message = "Prefix must be provided if name_override is not provided."
  }
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."

  default = {}
}