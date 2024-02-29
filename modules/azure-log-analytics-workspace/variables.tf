variable "project" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The name of the environment"
  type        = string
}

variable "location" {
  description = "The location/region of the resource group"
  type        = string
}

variable "create_in_environment" {
  description = "Whether to create the resource in the environment"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "workspace_name" {
  description = "The name of the Log Analytics Workspace"
  type        = string
}

variable "sku" {
  description = "The SKU of the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "The retention period for the Log Analytics Workspace"
  type        = number
  default     = 30
}
