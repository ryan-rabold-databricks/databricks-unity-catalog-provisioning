# Databricks Schema Module Outputs

output "schema_id" {
  description = "The ID of the created schema"
  value       = databricks_schema.this.id
}

output "schema_full_name" {
  description = "The full name of the schema (catalog.schema)"
  value       = "${var.catalog_name}.${var.schema_name}"
}

output "schema_name" {
  description = "The name of the schema"
  value       = databricks_schema.this.name
}

output "catalog_name" {
  description = "The name of the catalog"
  value       = databricks_schema.this.catalog_name
}

