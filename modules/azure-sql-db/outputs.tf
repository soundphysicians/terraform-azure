
output "sql_fully_qualified_domain_name" {
  value       = azurerm_mssql_server.server.fully_qualified_domain_name
  description = "The fully qualified domain name of the SQL server"
  sensitive   = false
}

output "sql_database_name" {
  value       = azurerm_mssql_database.db.name
  description = "The name of the database on the Azure SQL server"
  sensitive   = false
}

output "database_url" {
  value       = "${azurerm_mssql_server.server.name}.database.windows.net:1433;database=${azurerm_mssql_database.db.name};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
  description = "The Azure SQL server URL."
}

output "database_username" {
  value       = "${var.administrator_login}@${azurerm_mssql_server.server.name}"
  description = "The Azure SQL server user name."
}

output "database_password" {
  value       = random_password.password.result
  sensitive   = true
  description = "The Azure SQL server password."
}
