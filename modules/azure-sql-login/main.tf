terraform {
  required_providers {
    mssql = {
      source  = "betr-io/mssql"
      version = "~> 0.2.4"
    }
  }
}

resource "random_password" "password" {
  count            = var.password == null ? 1 : 0
  length           = 32
  special          = true
  override_special = "_%@"
}

locals {
  password = (
    var.password != null ?
    var.password :
    random_password.password[0].result
  )
}

resource "mssql_login" "login" {
  server {
    host = var.sql_fully_qualified_domain_name
    login {
      username = var.sql_admin_username
      password = var.sql_admin_password
    }
  }
  login_name       = var.username
  password         = local.password
  default_database = var.database_name
}

resource "mssql_user" "user" {
  server {
    host = var.sql_fully_qualified_domain_name
    login {
      username = var.sql_admin_username
      password = var.sql_admin_password
    }
  }
  database   = var.database_name
  username   = mssql_login.login.login_name
  login_name = mssql_login.login.login_name
  roles      = var.roles
}
