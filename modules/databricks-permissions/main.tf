# Databricks Permissions Module
# Grants permissions on a schema to a specified group
# Uses databricks_grant (singular) to manage individual grants
# This allows multiple groups to have permissions without interfering with each other

resource "databricks_grant" "schema_grant" {
  schema     = var.schema_full_name
  principal  = var.group_name
  privileges = var.privileges
}

