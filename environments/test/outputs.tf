# Output Values for Test Environment
#
# These outputs provide information about the created resources
# and can be used for integration with other systems or documentation.

output "catalog_name" {
  description = "Name of the Unity Catalog used"
  value       = var.catalog_name
}

output "schemas" {
  description = "Details of all created schemas"
  value = {
    for key, schema in module.databricks_schema : key => {
      schema_id        = schema.schema_id
      schema_name      = schema.schema_name
      schema_full_name = schema.schema_full_name
    }
  }
}

output "permissions" {
  description = "Details of all granted permissions"
  value = {
    for key, perm in module.databricks_permissions : key => {
      principal          = perm.principal
      schema_full_name   = perm.schema_full_name
      granted_privileges = perm.granted_privileges
    }
  }
}

output "schema_summary" {
  description = "Summary of schemas by catalog"
  value = {
    catalog        = var.catalog_name
    total_schemas  = length(module.databricks_schema)
    schema_names   = [for schema in module.databricks_schema : schema.schema_name]
  }
}

output "environment" {
  description = "Current environment name"
  value       = var.environment
}

