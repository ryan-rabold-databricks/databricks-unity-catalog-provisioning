# Databricks Permissions Module Outputs

output "grant_id" {
  description = "The ID of the grant resource"
  value       = databricks_grant.schema_grant.id
}

output "granted_privileges" {
  description = "The privileges that were granted"
  value       = var.privileges
}

output "principal" {
  description = "The principal (group) that received the grants"
  value       = var.group_name
}

output "schema_full_name" {
  description = "The full name of the schema that permissions were granted on"
  value       = var.schema_full_name
}

