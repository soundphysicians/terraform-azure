output "master_roles" {
  value       = mssql_user.master.roles
  sensitive   = false
  description = "Roles assigned the user in the master database."
}

output "application_roles" {
  value       = mssql_user.appDb.roles
  sensitive   = false
  description = "Roles assigned the user in the application database."
}

output "username" {
  value       = mssql_user.appDb.username
  sensitive   = false
  description = "The Azure SQL user name."
}