terraform {
  required_providers {
    mssql = {
      source  = "betr-io/mssql"
      version = "~> 0.2.4"
    }
  }
}
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

resource "mssql_user" "master" {
  server {
    host = var.sql_server_fqdn
    login {
      username = var.sql_server_admin_username.value
      password = var.sql_server_admin_password.value
    }
  }
  database  = "master"
  username  = var.db_user.username
  object_id = var.db_user.object_id
  roles     = []
}

resource "mssql_user" "appDb" {
  server {
    host = var.sql_server_fqdn
    login {
      username = var.sql_server_admin_username.value
      password = var.sql_server_admin_password.value
    }
  }
  database  = var.db_name
  username  = var.db_user.username
  object_id = var.db_user.object_id
  roles     = var.db_user.roles
}
