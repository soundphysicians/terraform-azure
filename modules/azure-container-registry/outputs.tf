output "registry_name" {
  value = data.azurerm_container_registry.this.name
}

output "login_server" {
  value = data.azurerm_container_registry.this.login_server
}

output "admin_username" {
  value = data.azurerm_container_registry.this.admin_username
}

output "admin_password" {
  value = data.azurerm_container_registry.this.admin_password
}
