# Databricks Schema Module Variables

variable "catalog_name" {
  description = "Name of the Databricks catalog where the schema will be created"
  type        = string
}

variable "schema_name" {
  description = "Name of the schema to create"
  type        = string
}

variable "schema_comment" {
  description = "Comment/description for the schema"
  type        = string
  default     = ""
}

variable "schema_properties" {
  description = "Custom properties for the schema"
  type        = map(string)
  default     = {}
}

