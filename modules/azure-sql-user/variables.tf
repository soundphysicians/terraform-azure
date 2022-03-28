variable "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server instance to connect to"
}

variable "sql_server_admin_username" {
  description = "Key vault secret containing the sql admin username"
  type = object({
    value = string
  })
}

variable "sql_server_admin_password" {
  description = "Key vault secret containing the sql admin password"
  type = object({
    value = string
  })
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
    roles     = list(string)
  })
}
