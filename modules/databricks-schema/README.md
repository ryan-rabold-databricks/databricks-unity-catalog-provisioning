# Databricks Schema Module

This module creates a schema in a Databricks Unity Catalog.

## Purpose

This child module encapsulates the logic for creating a Databricks schema with configurable properties. It demonstrates how to create focused, reusable modules that can be orchestrated by a root module.

## Resources Created

- `databricks_schema` - A schema in the specified catalog

## Usage

```hcl
module "databricks_schema" {
  source = "./modules/databricks-schema"

  catalog_name      = "my_catalog"
  schema_name       = "my_schema"
  schema_comment    = "This is my schema"
  schema_properties = {
    environment = "dev"
    team        = "data-engineering"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| catalog_name | Name of the Databricks catalog where the schema will be created | string | n/a | yes |
| schema_name | Name of the schema to create | string | n/a | yes |
| schema_comment | Comment/description for the schema | string | "" | no |
| schema_properties | Custom properties for the schema | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| schema_id | The ID of the created schema |
| schema_full_name | The full name of the schema (catalog.schema) |
| schema_name | The name of the schema |
| catalog_name | The name of the catalog |

