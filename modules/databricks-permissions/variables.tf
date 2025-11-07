# Databricks Permissions Module Variables

variable "schema_full_name" {
  description = "Full name of the schema (catalog.schema) to grant permissions on"
  type        = string
}

variable "group_name" {
  description = "Name of the group to grant permissions to"
  type        = string
}

variable "privileges" {
  description = "List of privileges to grant to the group"
  type        = list(string)
}

