# Development Environment - Databricks Unity Catalog Schema Provisioning
#
# This configuration manages schemas and permissions in the development environment.
# It uses a data-driven approach where schema definitions are stored in JSON files.

terraform {
  required_version = ">= 1.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
  }

  # Backend configuration for remote state management
  # Uncomment and configure when ready for team collaboration
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "tfstate<unique_id>"
  #   container_name       = "tfstate"
  #   key                  = "databricks/dev/terraform.tfstate"
  # }
}

# Provider configuration
# Authentication can be done via:
# 1. Databricks CLI profile (local development)
# 2. Environment variables (CI/CD)
# 3. Azure AD Service Principal (production)
provider "databricks" {
  # host  = var.databricks_host
  # token = var.databricks_token
  # Or use environment variables:
  # DATABRICKS_HOST, DATABRICKS_TOKEN
  # ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID
}

# Load all schema definitions from JSON files
locals {
  # Find all JSON files in the schemas/dev directory
  schema_files = fileset(path.module, "../../schemas/${var.environment}/*.json")

  # Parse each JSON file and create a map of schemas
  schemas_raw = {
    for file in local.schema_files :
    replace(basename(file), ".json", "") => jsondecode(file("${path.module}/../../schemas/${var.environment}/${file}"))
  }

  # Transform the schema definitions into the format expected by the modules
  schemas = {
    for key, schema in local.schemas_raw : key => {
      schema_name       = schema.schema_name
      schema_comment    = schema.schema_comment
      schema_properties = schema.schema_properties
      group_name        = schema.group_name
      privileges        = schema.privileges
    }
  }
}

# Module: Create Databricks Schemas
# This module creates Unity Catalog schemas based on the JSON definitions
module "databricks_schema" {
  source   = "../../modules/databricks-schema"
  for_each = local.schemas

  catalog_name      = var.catalog_name
  schema_name       = each.value.schema_name
  schema_comment    = each.value.schema_comment
  schema_properties = each.value.schema_properties
}

# Module: Grant Permissions on Schemas
# This module grants permissions to groups for each schema
module "databricks_permissions" {
  source   = "../../modules/databricks-permissions"
  for_each = local.schemas

  schema_full_name = module.databricks_schema[each.key].schema_full_name
  group_name       = each.value.group_name
  privileges       = each.value.privileges

  # Ensure schema is created before applying permissions
  depends_on = [module.databricks_schema]
}

