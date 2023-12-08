variables {
  sql_fully_qualified_domain_name = "my.database.server.azure.net"
  database_name                   = "my_database"
  sql_admin_password              = "blah"
  sql_admin_username              = "foo"
  username                        = "test_user"
  roles                           = ["db_datareader", "db_datawriter"]
}

run "should_set_server_name" {
    command= plan 

    assert {
        condition = mssql_login.login.server[0].host == var.sql_fully_qualified_domain_name
        error_message = "Should set server host"
    }
}

run "should_require_server_name_greater_than_10_characters" {
    command= plan 

    variables {
        sql_fully_qualified_domain_name = "0123456789"
    }

    expect_failures = [
        var.sql_fully_qualified_domain_name
    ]
}

run "should_set_admin_username_and_password" {
    command= plan 

    assert {
        condition = mssql_login.login.server[0].login[0].username == var.sql_admin_username && mssql_login.login.server[0].login[0].password == var.sql_admin_password
        error_message = "Should set admin username and password"
    }
}

run "should_require_admin_username_minimum_length" {
    command= plan 

    variables {
        sql_admin_username = "a"
    }

    expect_failures = [
        var.sql_admin_username
    ]
}

run "should_require_admin_password_minimum_length" {
    command= plan 

    variables {
        sql_admin_password = "ab"
    }

    expect_failures = [
        var.sql_admin_password
    ]
}

run "should_set_user_login_name" {
    command= plan 

    assert {
        condition = mssql_login.login.login_name == var.username
        error_message = "Should set user login name"
    }
}

run "should_require_username_minimum_length" {
    command= plan 

    variables {
        username = "a"
    }

    expect_failures = [
        var.username
    ]
}

run "should_set_user_default_database" {
    command= plan 

    assert {
        condition = mssql_login.login.default_database == var.database_name
        error_message = "Should set user default database"
    }
}

run "should_require_user_default_database" {
    command= plan 

    variables {
        database_name = ""
    }

    expect_failures = [
        var.database_name
    ]
}

run "can_use_provided_password" {
    command= plan 

    variables {
        password = "myB@dpass"
    }

    assert {
        condition = mssql_login.login.password == var.password
        error_message = "Should generate a password"
    }
}

run "should_require_password_minimum_length" {
    command= plan 

    variables {
        password = "0123456"
    }

    expect_failures = [
        var.password
    ]
}
