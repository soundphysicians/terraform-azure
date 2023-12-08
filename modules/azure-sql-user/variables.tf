variable "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server instance to connect to"
}

variable "sql_server_admin_username" {
  description = "Name of the sql administrator login"
  type        = string
}

variable "sql_server_admin_password" {
  description = "Password for the sql administrator login"
  type        = string
}

variable "db_name" {
  description = "Name of the SQL database"
  type        = string
}

variable "db_user" {
  description = "The user to grant access to the database"
  type = object({
    username  = string,
    object_id = string,
    roles     = list(string),
    master_roles = list(string)
  })
  default = {
    username = null
    object_id = null
    roles = []
    master_roles = []
  }
  validation {
    condition = var.db_user.username != null && var.db_user.object_id != null
    error_message = "db_user.username and db_user.object_id must be set"
  }
}
