variable "project" {
  description = "The name of the project, used for resource tagging"
  type        = string
}

variable "prefix" {
  description = "The prefix which becomes the first segment of all resource names"
  type        = string
}

variable "suffix" {
  description = "The suffix which becomes the last segment of all resource names"
  type        = string
}

variable "environment" {
  type        = string
  description = <<EOT
  (Optional) The environment short name to use for the deployed resources.

  Options:
  - tdd
  - dev
  - tst
  - uat
  - prd

  Default: tdd
  EOT
  nullable    = false
  default     = "tdd"
  validation {
    condition     = can(regex("^tdd$|^dev$|^tst$|^uat$|^prd$", var.environment))
    error_message = "Environment must match existing environments list"
  }
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to place resources in"
  nullable    = false
}

variable "app_name" {
  description = "The name of the web app. Overrides the default naming convention"
  type        = string
  default     = null
}

variable "plan_name" {
  description = "The name of the web app service plan. Overrides the default naming convention"
  type        = string
  default     = null
}

variable "custom_domain_name" {
  type        = string
  description = "Root url for the production environment, if a static name is required"
  default     = null
  nullable    = true
  validation {
    condition     = var.custom_domain_name == null || can(regex("^(\\w*\\.)?\\w*.\\w*$", var.custom_domain_name))
    error_message = "The custom_domain_name must in the format subdomain.domain.rootDomain (subdomain is optional)."
  }
}

variable "devtest_port" {
  type        = number
  description = "Port number to use for local development to support authentication redirects"
  default     = null
  validation {
    condition     = var.devtest_port == null ? true : (var.devtest_port >= 3000 && var.devtest_port < 100000)
    error_message = "Must be a valid port number for devtest_port"
  }
}

variable "required_graph_access" {
  type = list(object({
    id   = string
    type = string
  }))
  description = "Set of graph resources the web app requires"
  validation {
    condition = alltrue([
      for o in var.required_graph_access : contains(["Scope"], o.type)
    ])
    error_message = "All required resource access must be of type 'Scope'"
  }
  nullable = true
  default  = []
}

variable "supported_app_roles" {
  type = list(object({
    id           = string
    description  = string
    display_name = string
    enabled      = bool
    value        = string
  }))
  description = "Set of roles that the application supports"
  default     = []
  nullable    = false
}

variable "test_automation_application_id" {
  type        = string
  nullable    = true
  description = "Application used for test automation"
  default     = null
}

variable "app_role_assignments" {
  description = "Set of fixed users and roles for the application"
  type = list(object({
    application_object_id = string,      # Azure AD Client ID for the client application 
    role_ids              = list(string) # list of roles that the application has access to
  }))
  nullable = false
  default  = []
}

variable "key_vault" {
  description = "Key vault to use for secrets"
  type = object({
    name                = string,
    resource_group_name = string
  })
  default  = null
  nullable = true
  validation {
    condition     = var.key_vault == null ? true : can(regex("^[a-zA-Z0-9-]*$", var.key_vault.name))
    error_message = "The key_vault name must be alphanumeric and contain only hyphens"
  }

  validation {
    condition     = var.key_vault == null ? true : length(var.key_vault.resource_group_name) > 0
    error_message = "The key_vault resource group name must be provided"
  }
}

variable "app_settings" {
  type        = map(string)
  description = "Key value pairs of settings to pass as application settings"
  default     = {}
  nullable    = false
}

variable "connection_strings" {
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  description = "Collection of connection strings used by the application"
  default     = []
  nullable    = false
  validation {
    condition = alltrue([
      for o in var.connection_strings : contains(["SQLServer", "MySQL", "PostgreSQL", "SQLAzure", "Custom"], o.type)
    ])
    error_message = "All connection strings must be of type 'SQLServer', 'MySQL', 'PostgreSQL', 'SQLAzure', or 'Custom'"
  }
}

variable "dotnet_framework_version" {
  type        = string
  description = "Version of the dotnet framework to run"
  default     = "8.0"
  nullable    = false
  validation {
    condition     = can(regex("^[0-9.]*$", var.dotnet_framework_version))
    error_message = "The dotnet_framework_version must be in the format [0-9.]*"
  
  }
}

variable "health_check_path" {
  type        = string
  description = "Path to the health check endpoint inside the application. ex. /health"
  default     = null
  nullable    = true
}

variable "web_app_sku_name" {
  type        = string
  description = "The SKU for the web app plan. Possible values include: B1, B2, B3, D1, F1, P1v2, P2v2, P3v2, P0v3, P1v3, P2v3, P3v3, P1mv3, P2mv3, P3mv3, P4mv3, P5mv3, S1, S2, S3, SHARED, WS1, WS2, and WS3"
  default     = "B1"
  nullable    = false
  validation {
    condition     = can(regex("^(B1|B2|B3|D1|F1|P1v2|P2v2|P3v2|P0v3|P1v3|P2v3|P3v3|P1mv3|P2mv3|P3mv3|P4mv3|P5mv3|S1|S2|S3|SHARED|WS1|WS2|WS3)$", var.web_app_sku_name))
    error_message = "The web_app_sku_name must be one of the following: B1, B2, B3, D1, F1, P1v2, P2v2, P3v2, P0v3, P1v3, P2v3, P3v3, P1mv3, P2mv3, P3mv3, P4mv3, P5mv3, S1, S2, S3, SHARED, WS1, WS2, WS3"  
  }
}

variable "remote_debugging_enabled" {
  type        = bool
  description = "Enable remote debugging for the web app"
  default     = false
  nullable    = false
}
