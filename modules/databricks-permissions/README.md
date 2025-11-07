# Databricks Permissions Module

This module grants permissions on a Databricks schema to a specified group.

## Purpose

This child module encapsulates the logic for granting permissions on Databricks Unity Catalog objects. It demonstrates how to create focused, reusable modules for access management that can be orchestrated by a root module.

**Important:** This module uses `databricks_grant` (singular) instead of `databricks_grants` (plural). This allows you to call this module multiple times for different groups without one grant overwriting another. Each grant is managed independently.

## Resources Created

- `databricks_grant` - Grants permissions on a schema to a single group

## Usage

### Single Group

```hcl
module "databricks_permissions" {
  source = "./modules/databricks-permissions"

  schema_full_name = "my_catalog.my_schema"
  group_name       = "data_engineers"
  privileges       = ["USE_SCHEMA", "CREATE_TABLE", "SELECT"]
}
```

### Multiple Groups (Recommended Pattern)

Because this module uses `databricks_grant` (singular), you can safely call it multiple times for different groups:

```hcl
# Grant permissions to engineers
module "permissions_engineers" {
  source = "./modules/databricks-permissions"

  schema_full_name = "my_catalog.my_schema"
  group_name       = "data_engineers"
  privileges       = ["USE_SCHEMA", "CREATE_TABLE", "SELECT", "MODIFY"]
}

# Grant read-only permissions to analysts
module "permissions_analysts" {
  source = "./modules/databricks-permissions"

  schema_full_name = "my_catalog.my_schema"
  group_name       = "data_analysts"
  privileges       = ["USE_SCHEMA", "SELECT"]
}

# Grant admin permissions to admins
module "permissions_admins" {
  source = "./modules/databricks-permissions"

  schema_full_name = "my_catalog.my_schema"
  group_name       = "data_admins"
  privileges       = ["ALL_PRIVILEGES"]
}
```

Each module call manages its own grant independently, so permissions for one group won't affect permissions for other groups.

## Common Privileges

For schemas, common privileges include:
- `USE_SCHEMA` - Ability to use the schema
- `CREATE_TABLE` - Ability to create tables in the schema
- `CREATE_FUNCTION` - Ability to create functions in the schema
- `CREATE_VIEW` - Ability to create views in the schema
- `SELECT` - Ability to select from all tables in the schema
- `MODIFY` - Ability to modify all tables in the schema
- `ALL_PRIVILEGES` - All privileges on the schema

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| schema_full_name | Full name of the schema (catalog.schema) to grant permissions on | string | n/a | yes |
| group_name | Name of the group to grant permissions to | string | n/a | yes |
| privileges | List of privileges to grant to the group | list(string) | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| grant_id | The ID of the grant resource |
| granted_privileges | The privileges that were granted |
| principal | The principal (group) that received the grants |
| schema_full_name | The full name of the schema that permissions were granted on |

