# Databricks Schema Module
# Creates a schema in the specified catalog

resource "databricks_schema" "this" {
  catalog_name = var.catalog_name
  name         = var.schema_name
  comment      = var.schema_comment
  properties   = var.schema_properties
}

