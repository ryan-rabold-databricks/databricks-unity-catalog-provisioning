# Input Variables for Development Environment

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "catalog_name" {
  description = "Name of the Databricks Unity Catalog where schemas will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9_]+$", var.catalog_name))
    error_message = "Catalog name must be lowercase alphanumeric with underscores only."
  }
}

variable "databricks_host" {
  description = "Databricks workspace URL (e.g., https://adb-xxx.azuredatabricks.net)"
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.databricks_host == null || can(regex("^https://", var.databricks_host))
    error_message = "Databricks host must start with https://."
  }
}

variable "databricks_token" {
  description = "Databricks Personal Access Token for authentication"
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Common tags to apply to all resources for tracking and organization"
  type        = map(string)
  default = {
    managed_by  = "terraform"
    environment = "dev"
    project     = "databricks-unity-catalog"
  }
}

