terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

#--------------------------------------------------------------
# Resource Group: Gets a reference to an existing group
#--------------------------------------------------------------
data "azurerm_resource_group" "app" {
  name = var.resource_group_name
}

resource "random_uuid" "webapp" {
  keepers = {
    app_name = local.app_name
  }
}

locals {
  tags = {
    project     = var.project
    environment = var.environment
  }

  # Role Definitions
  role_user_impersonation = {
    id   = random_uuid.webapp.result
    name = "user_impersonation"
  }

  # App Definitions
  app_azure_cli = {
    id           = "04b07795-8ddb-461a-bbee-02f9e1bf7b46"
    display_name = "Azure CLI"
  }

  # Set the name of the web app
  app_name  = coalesce(var.app_name, "${var.prefix}-${var.environment}-webapp-${var.suffix}")
  plan_name = coalesce(var.plan_name, "${var.prefix}-${var.environment}-asplan-${var.suffix}")

  # Set the custom domain name for the web app, if provided. This supports the use of a custom domain name for the web app
  custom_domain_name = var.custom_domain_name == null ? null : "https://${var.custom_domain_name}"

  # Set the identifier URI for the web app (used for authentication scopes)
  webapp_identifier = "https://${local.app_name}"

  # Set the redirect URIs for the web app
  redirect_uris = compact([
    "${local.webapp_identifier}.azurewebsites.net/signin-oidc/",
    local.custom_domain_name == null ? "" : "${local.custom_domain_name}/signin-oidc/",
    var.devtest_port == null ? null : "http://localhost:${var.devtest_port}/signin-oidc/"
  ])

  # Set the identifier URIs for the web app
  identifier_uris = compact([
    local.webapp_identifier,
    try(local.custom_domain_name, "")
  ])

  # Set the homepage URL property of the web app
  homepage_url = try(local.custom_domain_name, "${local.webapp_identifier}.azurewebsites.net")

  # Set the graph access for the web app
  default_graph_access = [
    {
      id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182" # offline_access Delegated	
      type = "Scope"
      }, {
      id   = "37f7f235-527c-4136-accd-4a02d197296e" # openid	Delegated	
      type = "Scope"
      }, {
      id   = "14dad69e-099b-42c9-810b-d002981feec1" # profile	Delegated	
      type = "Scope"
    }
  ]

  # Create a map of the default graph access requirements 
  default_graph_access_map = { for item in local.default_graph_access : item.id => item }
  custom_graph_access_map  = { for item in var.required_graph_access : item.id => item }

  # Merge the default and custom graph access requirements
  graph_access_map = merge(local.default_graph_access_map, local.custom_graph_access_map)
  graph_access_set = toset(values(local.graph_access_map))
}

#--------------------------------------------------------------
# Web App Registration: Creates an app registration for the web app
#--------------------------------------------------------------
resource "azuread_application" "webapp" {
  display_name                   = local.app_name
  owners                         = [data.azuread_client_config.current.object_id]
  sign_in_audience               = "AzureADMyOrg"
  group_membership_claims        = ["None"]
  fallback_public_client_enabled = false
  identifier_uris                = local.identifier_uris

  # Create app roles based on roles specified via variables
  dynamic "app_role" {
    for_each = var.supported_app_roles
    iterator = role
    content {
      allowed_member_types = ["User", "Application"]
      id                   = role.value.id
      description          = role.value.description
      display_name         = role.value.display_name
      enabled              = role.value.enabled
      value                = role.value.value
    }
  }

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2

    known_client_applications = compact([
      try(var.test_automation_application_id, "")
    ])

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access ${local.app_name} on behalf of the signed-in user"
      admin_consent_display_name = "Access ${local.app_name}"
      enabled                    = true
      id                         = local.role_user_impersonation.id
      type                       = "User"
      user_consent_description   = "Allow the application to access ${local.app_name} on your behalf"
      user_consent_display_name  = "Access ${local.app_name}"
      value                      = local.role_user_impersonation.name
    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    dynamic "resource_access" {
      for_each = local.graph_access_set
      iterator = access
      content {
        id   = access.value["id"]
        type = access.value["type"]
      }
    }
  }

  web {
    redirect_uris = local.redirect_uris
    homepage_url  = local.homepage_url

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }

  tags = values(local.tags)
}

#--------------------------------------------------------------
# Web App Registration Pre-Authorized: Grants pre-authorization to the Azure CLI
#--------------------------------------------------------------
resource "azuread_application_pre_authorized" "azure-cli" {
  application_id       = azuread_application.webapp.id
  authorized_client_id = local.app_azure_cli.id             // Azure CLI client Id
  permission_ids       = [local.role_user_impersonation.id] // user_impersonation
}

#--------------------------------------------------------------
# Web App Registration Password: Creates a client secret for the web app
#--------------------------------------------------------------
resource "azuread_application_password" "webapp_1" {
  application_id    = azuread_application.webapp.id
  display_name      = "Client Secret for ${local.app_name} (1)"
  end_date          = timeadd(timestamp(), "17520h") # 2 years
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [end_date, end_date_relative]
  }
}

#--------------------------------------------------------------
# Web App Service Principal: Creates a service principal 
# for the web app, allowing it to access resources
#--------------------------------------------------------------
resource "azuread_service_principal" "webapp" {
  client_id                    = azuread_application.webapp.client_id
  app_role_assignment_required = false
  alternative_names            = []
  notification_email_addresses = []
  owners                       = [data.azuread_client_config.current.object_id]
  tags                         = values(local.tags)

  lifecycle {
    ignore_changes = [id]
  }
}

#--------------------------------------------------------------
# Test Automation Account service principal 
#--------------------------------------------------------------
data "azuread_service_principal" "test_automation" {
  count     = var.test_automation_application_id == null ? 0 : 1
  client_id = var.test_automation_application_id
}

#--------------------------------------------------------------
# Permissions 
#--------------------------------------------------------------
locals {
  # Generate a list of app role assignments for the test automation application
  # to access to web application
  automation_permission_ids = [
    for role in azuread_application.webapp.app_role : [
      role.id
    ] if(var.test_automation_application_id != null)
  ]

  # Generate a list of app role assignments for access to the web app
  fixed_app_permissions = distinct(flatten([
    for user in var.app_role_assignments : [
      for role in user.role_ids : {
        application_object_id = user.application_object_id
        role_id               = role
        unique_key            = format("%s-%s", user.application_object_id, role)
      }
    ] if length(user.role_ids) > 0
  ]))

  # Generate a map of app role assignments for access to the web app
  fixed_app_permissions_map = {
    for each in local.fixed_app_permissions : each.unique_key => { application_object_id = each.application_object_id, role_id = each.role_id }
  }
}

#--------------------------------------------------------------
# Web Application Fixed Roles for Test Automation
#--------------------------------------------------------------
resource "azuread_app_role_assignment" "test-automation" {
  for_each            = toset(local.automation_permission_ids)
  app_role_id         = each.value
  principal_object_id = data.azuread_service_principal.test_automation[0].object_id
  resource_object_id  = azuread_service_principal.webapp.object_id
}

#--------------------------------------------------------------
# Web Application Fixed Roles for Applications
#--------------------------------------------------------------
resource "azuread_app_role_assignment" "api-role-assignments" {
  for_each            = local.fixed_app_permissions_map
  app_role_id         = each.value.role_id
  principal_object_id = each.value.application_object_id
  resource_object_id  = azuread_service_principal.webapp.object_id
  depends_on = [
    azuread_application.webapp
  ]
}

#--------------------------------------------------------------
# Web Application App Service Plan 
#--------------------------------------------------------------
resource "azurerm_app_service_plan" "webapp" {
  name                = local.plan_name
  location            = data.azurerm_resource_group.app.location
  resource_group_name = data.azurerm_resource_group.app.name
  sku {
    tier = var.web_app_plan_type.tier
    size = var.web_app_plan_type.size
  }

  tags = local.tags
}

#--------------------------------------------------------------
# Managed Identity for the Web App. Used to grant access to resources 
# such as Key Vault, Storage, etc.
#--------------------------------------------------------------
resource "azurerm_user_assigned_identity" "webapp" {
  name                = azuread_application.webapp.display_name
  resource_group_name = data.azurerm_resource_group.app.name
  location            = data.azurerm_resource_group.app.location

  tags = local.tags
}


#--------------------------------------------------------------
# Key Vault Access Policy: Grants the web app access to the key vault
#--------------------------------------------------------------
data "azurerm_key_vault" "mercury" {
  count               = var.key_vault == null ? 0 : 1
  name                = var.key_vault.name
  resource_group_name = var.key_vault.resource_group_name
}

resource "azurerm_key_vault_access_policy" "webapp" {
  count        = var.key_vault == null ? 0 : 1
  key_vault_id = data.azurerm_key_vault.mercury[0].id

  tenant_id = azurerm_user_assigned_identity.webapp.tenant_id
  object_id = azurerm_user_assigned_identity.webapp.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

#--------------------------------------------------------------
# Web App App Service: Creates the web app
#--------------------------------------------------------------
resource "azurerm_app_service" "webapp" {
  name                = azuread_application.webapp.display_name
  location            = data.azurerm_resource_group.app.location
  resource_group_name = data.azurerm_resource_group.app.name
  app_service_plan_id = azurerm_app_service_plan.webapp.id

  # Do not disable https requirement. Required by security
  https_only = true

  // Declares that we will handle authentication ourselves
  auth_settings {
    enabled = false
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.webapp.id
    ]
  }

  # Pass any application settings through, but include the required settings
  app_settings = merge(var.app_settings, {
    "WEBSITE_RUN_FROM_PACKAGE"         = 1,
    "AzureAd:ClientId"                 = azuread_application.webapp.client_id,
    "AzureAd:ClientSecret"             = azuread_application_password.webapp_1.value,
    "AZURE_CLIENT_ID"                  = azuread_application.webapp.client_id,
    "KeyVault:Enabled"                 = var.key_vault == null ? "false" : "true",
    "KeyVault:Environment"             = var.key_vault == null ? "" : var.environment,
    "KeyVault:Name"                    = var.key_vault == null ? "" : var.key_vault.name,
    "KeyVault:ManagedIdentityClientId" = var.key_vault == null ? "" : azurerm_user_assigned_identity.webapp.client_id,
  })

  # Pass any connection strings through
  dynamic "connection_string" {
    for_each = var.connection_strings
    iterator = connection_string
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  logs {
    failed_request_tracing_enabled  = true
    detailed_error_messages_enabled = true
    application_logs {
      file_system_level = "Information"
    }
  }

  site_config {
    # Do not disable http2. Required by security
    http2_enabled            = true
    managed_pipeline_mode    = "Integrated"
    min_tls_version          = 1.2
    dotnet_framework_version = var.dotnet_framework_version
    health_check_path        = var.health_check_path
    remote_debugging_enabled = var.remote_debugging_enabled
    remote_debugging_version = "VS2019"
  }

  lifecycle {
    ignore_changes = [
      app_settings.WEBSITE_RUN_FROM_PACKAGE
    ]
  }

  tags = local.tags
}