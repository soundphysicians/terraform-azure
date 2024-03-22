provider "azurerm" {
  features {}
}

variables {
  name = {
    prefix        = "tst",
    environment   = "tdd",
    base_name     = "myStorage",
    name_override = ""
  }
  location            = "westus3"
  resource_group_name = "tst-tdd-rg"
}

run "should_create_storage_account_with_reasonable_defaults" {
  command = plan

  assert {
    condition     = azurerm_storage_account.this.name == "tsttddsamystorage"
    error_message = "Should create storage account with correct derived name"
  }

  assert {
    condition     = azurerm_storage_account.this.resource_group_name == var.resource_group_name
    error_message = "Should set resource group from variable"
  }

  assert {
    condition     = azurerm_storage_account.this.location == var.location
    error_message = "Should set location from variable"
  }

  assert {
    condition     = azurerm_storage_account.this.account_kind == "StorageV2"
    error_message = "Should set account_kind to StorageV2"
  }

  assert {
    condition     = azurerm_storage_account.this.account_tier == "Standard"
    error_message = "Should set account_tier to Standard"
  }

  assert {
    condition     = azurerm_storage_account.this.access_tier == "Hot"
    error_message = "Should set access_tier to Hot"
  }

  assert {
    condition     = azurerm_storage_account.this.account_replication_type == "RAGRS"
    error_message = "Should set account_replication_type to RAGRS"
  }

  assert {
    condition     = azurerm_storage_account.this.enable_https_traffic_only == true
    error_message = "Should require https traffic only"
  }

  assert {
    condition     = azurerm_storage_account.this.min_tls_version == "TLS1_2"
    error_message = "Should require minimum TLS version 1.2"
  }

  assert {
    condition     = azurerm_storage_account.this.allow_nested_items_to_be_public == false
    error_message = "Should not allow nested items to be public"
  }
}

run "should_create_storage_account_with_name_override_if_provided" {
  command = plan

  variables {
    name = {
      prefix        = "tst",
      environment   = "tdd",
      base_name     = "myStorage",
      name_override = "tsttddsamyoverride"
    }
  }

  assert {
    condition     = azurerm_storage_account.this.name == var.name.name_override
    error_message = "Should create storage account with overridden name"
  }
}

run "should_create_storage_account_without_tags_if_not_provided_or_derived" {
  command = plan

  variables {
    name = {
      prefix        = null,
      environment   = null,
      base_name     = null,
      name_override = "tsttddsamyoverride"
    }
  }

  assert {
    condition     = azurerm_storage_account.this.tags == null
    error_message = "Should create tags as empty map when not provided or derived"
  }
}

run "should_create_storage_account_with_tags_if_provided" {
  command = plan

  variables {
    name = {
      prefix        = null,
      environment   = null,
      base_name     = null,
      name_override = "tsttddsamyoverride"
    }
    tags = {
      "tag1" = "value1",
      "tag2" = "value2"
    }
  }

  assert {
    condition     = length(azurerm_storage_account.this.tags) == 2
    error_message = "Should pass tags when provided"
  }

  assert {
    condition     = azurerm_storage_account.this.tags["tag1"] == "value1"
    error_message = "Should pass first tag when provided"
  }

  assert {
    condition     = azurerm_storage_account.this.tags["tag2"] == "value2"
    error_message = "Should pass second tag when provided"
  }
}

run "should_provide_tag_variables_with_provided_values" {
  command = plan

  variables {
    name = {
      prefix        = "ut",
      environment   = "tdd",
      base_name     = "mystorage",
      name_override = "tsttddsamyoverride"
    }
    tags = {
      "environment" = "tst",
      "project"     = "myproject"
    }
  }

  assert {
    condition     = length(azurerm_storage_account.this.tags) == 2
    error_message = "Should pass tags when provided"
  }

  assert {
    condition     = azurerm_storage_account.this.tags["environment"] == "tst"
    error_message = "Should pass first tag when provided"
  }

  assert {
    condition     = azurerm_storage_account.this.tags["project"] == "myproject"
    error_message = "Should pass second tag when provided"
  }
}

run "should_merge_tag_variable_with_derived_values" {
  command = plan

  variables {
    name = {
      prefix        = "ut",
      environment   = "tdd",
      base_name     = "mystorage",
      name_override = "tsttddsamyoverride"
    }
    tags = {
      "key1" = "value1",
      "key2" = "value2"
    }
  }

  assert {
    condition     = length(azurerm_storage_account.this.tags) == 4
    error_message = "Should pass tags when provided"
  }

  assert {
    condition     = azurerm_storage_account.this.tags["environment"] == "tdd"
    error_message = "Should pass environment tag when environment provided"
  }

  assert {
    condition     = azurerm_storage_account.this.tags["project"] == "ut"
    error_message = "Should pass project tag when prefix provided"
  }

  assert {
    condition     = azurerm_storage_account.this.tags["key1"] == "value1"
    error_message = "Should pass first tag when provided"
  }

  assert {
    condition     = azurerm_storage_account.this.tags["key2"] == "value2"
    error_message = "Should pass second tag when provided"
  }
}