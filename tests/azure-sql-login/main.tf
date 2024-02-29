terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.97"
    }
  }
}

module "can_use_generated_password" {
  source                          = "../../modules/azure-sql-login"
  sql_fully_qualified_domain_name = "my.database.server.azure.net"
  database_name                   = "my_database"
  sql_admin_password              = "blah"
  sql_admin_username              = "foo"
  username                        = "test_user"
  roles                           = ["db_datareader", "db_datawriter"]
}

output "test__can_use_generated_password__password" {
  value     = module.can_use_generated_password.password
  sensitive = true
}

module "can_use_provided_password" {
  source                          = "../../modules/azure-sql-login"
  sql_fully_qualified_domain_name = "my.database.server.azure.net"
  database_name                   = "my_database"
  sql_admin_password              = "blah"
  sql_admin_username              = "foo"
  username                        = "test_user"
  password                        = "myB@dpass"
  roles                           = ["db_datareader", "db_datawriter"]
}

output "test__can_user_provided_password__password" {
  value     = module.can_use_provided_password.password
  sensitive = true
}
