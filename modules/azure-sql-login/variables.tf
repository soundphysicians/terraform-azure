variable "sql_fully_qualified_domain_name" {
  description = "Fully qualified domain name of the SQL server"
  nullable    = false
  validation {
    condition     = var.sql_fully_qualified_domain_name != null && length(var.sql_fully_qualified_domain_name) > 10
    error_message = "A sql_fully_qualified_domain_name must be provided."
  }
}

variable "database_name" {
  description = "Name of the database to assign to the user"
  type        = string
  nullable    = false
  validation {
    condition     = var.database_name != null && length(var.database_name) > 2
    error_message = "A database name must be provided."
  }
}

variable "sql_admin_username" {
  description = "Username of the sql administrator account"
  sensitive   = false
  type        = string
  nullable    = false
  validation {
    condition     = var.sql_admin_username != null && length(var.sql_admin_username) >= 2
    error_message = "A sql admin username must be provided."
  }
}

variable "sql_admin_password" {
  description = "Password of the sql administrator account"
  sensitive   = true
  type        = string
  nullable    = false

  validation {
    condition     = var.sql_admin_password != null && length(var.sql_admin_password) > 2
    error_message = "A sql admin password must be provided."
  }

}

variable "username" {
  description = "Username for the SQL user"
  type        = string
  nullable    = false

  validation {
    condition     = var.username != null && length(var.username) >= 2
    error_message = "A user name must be provided."
  }
}

variable "password" {
  description = "Password for the SQL user"
  type        = string
  sensitive   = true
  nullable    = true
  default     = null

  validation {
    condition     = (var.password == null || length(coalesce(var.password, " ")) >= 8)
    error_message = "A password of 8 or more characters must be provided."
  }
}

variable "roles" {
  description = "Array of role names to assign to the user"
  type        = list(string)
  default     = []
}
