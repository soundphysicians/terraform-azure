provider "azurerm" {
  features {}
}

provider "azurecaf" {}

override_data {
  target = data.azurerm_resource_group.rg
  values = {
    id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/sbs-shr-rg"
    name     = "sbs-shr-rg"
    location = "eastus2"
  }
}

override_data {
  target = data.azurerm_container_registry.this
  values = {
    id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/sbs-shr-rg/providers/Microsoft.ContainerRegistry/registries/sbsshracr"
    name                = "sbsshracr"
    resource_group_name = "sbs-shr-rg"
    location            = "eastus2"
    admin_username      = "sbsshracr"
    admin_password      = "secretpassword"
    login_server        = "sbsshracr.azurecr.io"
  }
}

variables {
  name                = "sbsshracr"
  project             = "sbs"
  resource_group_name = "sbs-shr-rg"
  subscription_id     = "0399139d-4b82-4380-883f-1bea3e15ce96"
  should_create       = true
}

run "should_set_default_tags" {
  command = plan

  assert {
    condition     = lookup(azurerm_container_registry.this[0].tags, "environment") == "shr"
    error_message = "Should set environment tag on container registry"
  }

  assert {
    condition     = lookup(azurerm_container_registry.this[0].tags, "project") == var.project
    error_message = "Should set project tag on container registry"
  }
}

run "should_allow_additional_tags" {
  command = plan

  variables {
    tags = {
      "cost-center" = "1234"
      "owner"       = "platform-team"
    }
  }

  assert {
    condition     = lookup(azurerm_container_registry.this[0].tags, "cost-center") == "1234"
    error_message = "Should set cost-center tag on container registry"
  }

  assert {
    condition     = lookup(azurerm_container_registry.this[0].tags, "owner") == "platform-team"
    error_message = "Should set owner tag on container registry"
  }

  assert {
    condition     = lookup(azurerm_container_registry.this[0].tags, "environment") == "shr"
    error_message = "Should preserve environment tag on container registry"
  }

  assert {
    condition     = lookup(azurerm_container_registry.this[0].tags, "project") == var.project
    error_message = "Should preserve project tag on container registry"
  }
}

run "should_allow_caller_tags_to_override_base_tags" {
  command = plan

  variables {
    tags = {
      "Environment" = "custom-env"
      "Project"     = "custom-project"
    }
  }

  assert {
    condition     = lookup(azurerm_container_registry.this[0].tags, "Environment") == "custom-env"
    error_message = "Caller Environment tag should override base tag and preserve its key"
  }

  assert {
    condition     = lookup(azurerm_container_registry.this[0].tags, "Project") == "custom-project"
    error_message = "Caller Project tag should override base tag and preserve its key"
  }

  assert {
    condition     = !contains(keys(azurerm_container_registry.this[0].tags), "environment") && !contains(keys(azurerm_container_registry.this[0].tags), "project")
    error_message = "Base tags should be removed when caller keys differ only by case"
  }
}
