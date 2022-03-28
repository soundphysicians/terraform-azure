variable "project" {
  type        = string
  description = "Project Name"
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
  nullable    = false
}

variable "name" {
  type        = string
  description = "Container Registry Name. Must be alpha numeric only"
  nullable    = false
}

variable "subscription_id" {
  type        = string
  description = "The Container Registry subscription"
  nullable    = false
}

variable "should_create" {
  type        = bool
  description = "Should the registry be created in this environment"
  default     = false
}
