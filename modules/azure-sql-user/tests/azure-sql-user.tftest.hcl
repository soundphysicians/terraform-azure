variables {
  sql_server_fqdn = "my.database.server.azure.net"
  db_name         = "my_database"
  db_user = {
    username     = "test_user"
    object_id    = "29bfdc3c-95b2-4a6f-906f-59f715137d8d"
    roles        = []
    master_roles = []
  }
  sql_server_admin_username = "foo"
  sql_server_admin_password = "blah"
}

run "should_set_master_username" {
  command = plan

  assert {
    condition     = mssql_user.master.username == "test_user"
    error_message = "Master username should be test_user"
  }
}

run "should_set_master_object_id" {
  command = plan

  assert {
    condition     = mssql_user.master.object_id == var.db_user.object_id
    error_message = "Master object id should be set"
  }
}

run "should_set_app_db_username" {
  command = plan

  assert {
    condition     = mssql_user.appDb.username == "test_user"
    error_message = "Application db username should be test_user"
  }
}

run "should_set_app_db_object_id" {
  command = plan

  assert {
    condition     = mssql_user.appDb.object_id == var.db_user.object_id
    error_message = "Application DB object id should be set"
  }
}

run "should_not_require_master_roles" {
  command = plan

  variables {
    db_user = {
      username  = var.db_user.username
      object_id = var.db_user.object_id
      roles     = []
    }

  }

  assert {
    condition     = mssql_user.master.roles == null
    error_message = "Master roles should be null when not provided"
  }
}

run "should_set_master_roles_blank_by_default" {
  command = plan

  variables {
    db_user = {
      username     = var.db_user.username
      object_id    = var.db_user.object_id
      roles        = []
      master_roles = []
    }

  }

  assert {
    condition     = mssql_user.master.roles == null
    error_message = "Master roles should be null when not provided"
  }
}

run "should_set_master_roles_as_provided" {
  command = plan

  variables {
    db_user = {
      username     = var.db_user.username
      object_id    = var.db_user.object_id
      roles        = []
      master_roles = ["db_datareader", "db_datawriter"]
    }

  }

  assert {
    condition     = length(mssql_user.master.roles) == 2 && contains(mssql_user.master.roles, "db_datareader") && contains(mssql_user.master.roles, "db_datawriter")
    error_message = "Master roles should be saved as provided"
  }
}

run "should_not_require_app_roles" {
  command = plan

  variables {
    db_user = {
      username     = var.db_user.username
      object_id    = var.db_user.object_id
      roles        = null
      master_roles = []
    }

  }

  assert {
    condition     = mssql_user.appDb.roles == null
    error_message = "App roles should be null when not provided"
  }
}

run "should_set_app_roles_as_provided" {
  command = plan

  variables {
    db_user = {
      username     = var.db_user.username
      object_id    = var.db_user.object_id
      roles        = ["db_datareader", "db_datawriter", "db_manager"]
      master_roles = []
    }

  }

  assert {
    condition     = length(mssql_user.appDb.roles) == 3 && contains(mssql_user.appDb.roles, "db_datareader") && contains(mssql_user.appDb.roles, "db_datawriter") && contains(mssql_user.appDb.roles, "db_manager")
    error_message = "Application roles should be saved as provided"
  }
}