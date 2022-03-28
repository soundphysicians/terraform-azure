terraform {
  required_providers {
    mssql = {
      source  = "betr-io/mssql"
      version = "~> 0.2.4"
    }
  }
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
