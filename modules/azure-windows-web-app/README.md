# Azure Windows Web App Module

This module creates an Azure Windows Web App with Azure AD authentication integration.

## Features

- Creates an Azure AD Application Registration for the web app
- Configures OAuth2 permissions and scopes
- Creates a Windows App Service Plan
- Deploys a Windows Web App
- Configures managed identity for secure access to Azure resources
- Optional Key Vault integration
- Supports custom domain names
- Configurable .NET Framework versions

## Usage

```hcl
module "windows_web_app" {
  source = "../../modules/azure-windows-web-app"

  project             = "MyProject"
  prefix              = "myp"
  suffix              = "webapp"
  environment         = "dev"
  resource_group_name = "myp-dev-rg"

  dotnet_framework_version = "v8.0"
  web_app_sku_name        = "B2"

  key_vault = {
    name                = "myp-shr-kv"
    resource_group_name = "myp-shr-rg"
  }

  app_settings = {
    "MySetting" = "MyValue"
  }
}
```

## Key Differences from Linux Web App

- Uses `azurerm_windows_web_app` instead of `azurerm_linux_web_app`
- OS type is set to "Windows" in the service plan
- .NET Framework version format is `v8.0` instead of `8.0` (note the "v" prefix)
- Application stack configuration uses `current_stack = "dotnet"` with `dotnet_version`

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

