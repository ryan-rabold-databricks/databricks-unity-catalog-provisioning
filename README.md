# Databricks Unity Catalog Provisioning

A production-ready Terraform accelerator for provisioning and managing Databricks Unity Catalog schemas and permissions using a data-driven approach.

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.0-623CE4)](https://www.terraform.io/)
[![Databricks](https://img.shields.io/badge/Databricks-Unity%20Catalog-FF3621)](https://www.databricks.com/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Configuration](#configuration)
- [Examples](#examples)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Overview

This project provides a standardized, scalable way to manage Databricks Unity Catalog schemas and permissions across multiple environments using Terraform. It follows industry best practices and is designed to be used as an accelerator for organizations adopting Unity Catalog.

### Key Characteristics

- **Data-Driven**: Schema definitions stored in JSON files for easy management
- **Environment-Specific**: Separate configurations for dev, test, and prod
- **Modular**: Reusable Terraform modules for schemas and permissions
- **Production-Ready**: Follows Terraform and Databricks best practices
- **Self-Service**: Non-technical users can add schemas by creating JSON files
- **Auditable**: All changes tracked in version control

---

## ✨ Features

### Core Capabilities

- ✅ **Automated Schema Creation**: Create Unity Catalog schemas with properties
- ✅ **Permission Management**: Grant fine-grained permissions to groups
- ✅ **Multi-Environment Support**: Separate configurations for dev/test/prod
- ✅ **JSON-Based Definitions**: Simple schema definitions in JSON format
- ✅ **State Management**: Support for remote backends (Azure, S3, Terraform Cloud)
- ✅ **Input Validation**: Validates schema names and catalog names
- ✅ **Comprehensive Outputs**: Detailed outputs for integration
- ✅ **Authentication Flexibility**: Supports PAT, CLI profiles, and Azure AD

### Security & Governance

- 🔒 Sensitive variables properly marked
- 🔒 .gitignore configured to prevent secrets
- 🔒 Support for Azure AD Service Principal authentication
- 🔒 Least-privilege permission model
- 🔒 Audit trail through version control

---

## 🏗️ Architecture

### High-Level Design

```
┌─────────────────────────────────────────────────────────────┐
│                     JSON Schema Definitions                  │
│                  (schemas/dev/, test/, prod/)               │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Environment-Specific Configuration              │
│              (environments/dev/, test/, prod/)              │
│                                                              │
│  • Loads schema JSON files                                  │
│  • Passes data to modules                                   │
│  • Manages environment-specific variables                   │
└──────────────┬───────────────────────┬──────────────────────┘
               │                       │
               ▼                       ▼
┌──────────────────────┐    ┌────────────────────────┐
│  databricks-schema   │    │ databricks-permissions │
│      Module          │    │        Module          │
│                      │    │                        │
│ • Create schemas     │    │ • Grant permissions    │
│ • Set properties     │    │ • Assign to groups     │
└──────────┬───────────┘    └───────────┬────────────┘
           │                            │
           └────────────┬───────────────┘
                        ▼
           ┌─────────────────────────┐
           │  Databricks Workspace   │
           │    (Unity Catalog)      │
           └─────────────────────────┘
```

### Data Flow

1. **Schema Definition**: User creates/updates JSON file in `schemas/{env}/`
2. **Terraform Load**: Environment config loads and parses JSON files
3. **Module Invocation**: Passes schema data to reusable modules
4. **Resource Creation**: Modules create schemas and grant permissions
5. **State Update**: Terraform updates state with created resources
6. **Outputs**: Information about created resources available for integration

---

## 📦 Prerequisites

### Required

- **Terraform**: >= 1.0
- **Databricks Workspace**: With Unity Catalog enabled
- **Authentication**: One of the following:
  - Databricks Personal Access Token (PAT)
  - Databricks CLI configured profile
  - Azure AD Service Principal (recommended for production)
- **Permissions**: 
  - Unity Catalog CREATE SCHEMA privilege
  - Ability to grant permissions to groups

### Recommended

- **Remote Backend**: Azure Storage, AWS S3, or Terraform Cloud
- **Version Control**: Git repository for tracking changes
- **CI/CD Pipeline**: GitHub Actions, Azure DevOps, or similar (optional)

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd databricks-unity-catalog-provisioning
```

### 2. Choose Your Environment

```bash
cd environments/dev
```

### 3. Configure Variables

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

Update `catalog_name` with your Unity Catalog name:

```hcl
catalog_name = "dev_catalog"
environment  = "dev"
```

### 4. Set Up Authentication

```bash
# Option A: Environment variables (recommended)
export DATABRICKS_HOST="https://adb-xxx.azuredatabricks.net"
export DATABRICKS_TOKEN="your-token"

# Option B: Databricks CLI profile
export DATABRICKS_CONFIG_PROFILE="your-profile"

# Option C: Azure AD Service Principal
export ARM_CLIENT_ID="xxx"
export ARM_CLIENT_SECRET="xxx"
export ARM_TENANT_ID="xxx"
export DATABRICKS_HOST="https://adb-xxx.azuredatabricks.net"
```

### 5. Initialize Terraform

```bash
terraform init
```

### 6. Review the Plan

```bash
terraform plan
```

### 7. Apply Configuration

```bash
terraform apply
```

### 8. View Outputs

```bash
terraform output
```

---

## 📁 Project Structure

```
databricks-unity-catalog-provisioning/
├── README.md                          # This file
├── REFERENCED_BEST_PRACTICES.md      # Best practices guide
├── .gitignore                         # Git ignore patterns
│
├── modules/                           # Reusable Terraform modules
│   ├── databricks-schema/            # Schema creation module
│   │   ├── main.tf                   # Schema resource definition
│   │   ├── variables.tf              # Input variables
│   │   ├── outputs.tf                # Output values
│   │   ├── versions.tf               # Provider requirements
│   │   └── README.md                 # Module documentation
│   │
│   └── databricks-permissions/        # Permissions management module
│       ├── main.tf                   # Permissions resource definition
│       ├── variables.tf              # Input variables
│       ├── outputs.tf                # Output values
│       ├── versions.tf               # Provider requirements
│       └── README.md                 # Module documentation
│
├── environments/                      # Environment-specific configurations
│   ├── dev/                          # Development environment
│   │   ├── main.tf                   # Environment configuration
│   │   ├── variables.tf              # Variable definitions
│   │   ├── outputs.tf                # Output definitions
│   │   ├── terraform.tfvars.example  # Example values
│   │   ├── backend.tf.example        # Backend configuration example
│   │   └── README.md                 # Environment documentation
│   │
│   ├── test/                         # Test environment
│   │   └── ... (same structure as dev)
│   │
│   └── prod/                         # Production environment
│       └── ... (same structure as dev)
│
├── schemas/                           # Schema definitions (JSON files)
│   ├── dev/                          # Development schemas
│   │   └── analytics-team-schema.json
│   │
│   ├── test/                         # Test schemas
│   │   └── analytics-team-schema.json
│   │
│   └── prod/                         # Production schemas
│       └── analytics-team-schema.json
│
├── examples/                          # Usage examples
│   └── complete/                     # Complete working example
│       └── README.md
│
└── docs/                             # Additional documentation
    └── (future documentation)
```

### File Descriptions

#### Root Level

| File | Purpose |
|------|---------|
| `README.md` | Main project documentation |
| `REFERENCED_BEST_PRACTICES.md` | Terraform and Databricks best practices |
| `.gitignore` | Files to exclude from version control |

#### Modules Directory

Contains reusable Terraform modules that can be used across environments:

- **databricks-schema**: Creates Unity Catalog schemas with properties
- **databricks-permissions**: Grants permissions to groups on schemas

Each module follows the standard Terraform module structure with `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, and `README.md`.

#### Environments Directory

Contains environment-specific configurations (dev, test, prod). Each environment:

- Loads schema definitions from JSON files
- Calls the reusable modules
- Maintains separate state files
- Has environment-specific variables

#### Schemas Directory

Contains JSON files defining schemas for each environment. Schema definitions are separated by environment to allow for:

- Different schemas in different environments
- Environment-specific configurations
- Testing before promoting to production

---

## 💻 Usage

### Adding a New Schema

To add a new schema to an environment:

**Step 1: Create JSON Definition**

Create a JSON file in the appropriate environment directory:

```bash
# For development
nano schemas/dev/my-new-schema.json
```

**Step 2: Define Schema**

```json
{
  "schema_name": "my_new_schema",
  "schema_comment": "Description of my schema",
  "schema_properties": {
    "environment": "dev",
    "team": "my_team",
    "purpose": "data_analysis",
    "owner": "team@company.com"
  },
  "group_name": "my_databricks_group",
  "privileges": [
    "USE_SCHEMA",
    "CREATE_TABLE",
    "SELECT"
  ]
}
```

**Step 3: Apply Changes**

```bash
cd environments/dev
terraform plan
terraform apply
```

### Modifying an Existing Schema

**Step 1: Edit JSON File**

```bash
nano schemas/dev/existing-schema.json
```

**Step 2: Update Properties**

Modify the schema properties, comment, or permissions as needed.

**Step 3: Apply Changes**

```bash
cd environments/dev
terraform plan
terraform apply
```

### Removing a Schema

**⚠️ Warning**: This will delete the schema and all its contents!

**Step 1: Remove JSON File**

```bash
rm schemas/dev/schema-to-remove.json
```

**Step 2: Apply Changes**

```bash
cd environments/dev
terraform plan  # Review what will be destroyed
terraform apply
```

### Promoting from Dev to Test to Prod

**Step 1: Copy Schema Definition**

```bash
cp schemas/dev/my-schema.json schemas/test/
```

**Step 2: Update Environment Properties**

Edit the JSON file and change environment-specific properties:

```json
{
  "schema_properties": {
    "environment": "test",  // Change from "dev"
    ...
  }
}
```

**Step 3: Apply to Test**

```bash
cd environments/test
terraform plan
terraform apply
```

**Step 4: Repeat for Production**

After validation in test, promote to prod following the same process.

---

## ⚙️ Configuration

### Schema JSON Format

Each schema is defined in a JSON file with the following structure:

```json
{
  "schema_name": "string",              // Required: Schema name (lowercase, underscores)
  "schema_comment": "string",           // Required: Description of the schema
  "schema_properties": {                // Required: Key-value properties
    "environment": "dev|test|prod",    // Required: Environment
    "team": "string",                  // Recommended: Owning team
    "purpose": "string",               // Recommended: Purpose of schema
    "owner": "email",                  // Recommended: Contact email
    "cost_center": "string",           // Optional: For cost allocation
    "sla": "string",                   // Optional: SLA requirements
    "backup_policy": "string"          // Optional: Backup requirements
  },
  "group_name": "string",               // Required: Databricks group name
  "privileges": [                       // Required: Array of privileges
    "USE_SCHEMA",                      // Most common
    "CREATE_TABLE",
    "SELECT",
    "MODIFY"                           // Optional: For write access
  ]
}
```

### Available Privileges

| Privilege | Description |
|-----------|-------------|
| `USE_SCHEMA` | Required to access the schema |
| `SELECT` | Read data from tables/views |
| `MODIFY` | Update/delete data in tables |
| `CREATE_TABLE` | Create new tables in schema |
| `CREATE_VIEW` | Create views in schema |
| `CREATE_FUNCTION` | Create functions in schema |
| `USE_CATALOG` | Access parent catalog |
| `ALL_PRIVILEGES` | All available privileges (use cautiously) |

### Environment Variables

#### Authentication

```bash
# Databricks PAT
export DATABRICKS_HOST="https://adb-xxx.azuredatabricks.net"
export DATABRICKS_TOKEN="dapi..."

# Databricks CLI Profile
export DATABRICKS_CONFIG_PROFILE="profile-name"

# Azure AD Service Principal
export ARM_CLIENT_ID="xxx"
export ARM_CLIENT_SECRET="xxx"
export ARM_TENANT_ID="xxx"
export ARM_SUBSCRIPTION_ID="xxx"  # Optional but recommended
export DATABRICKS_HOST="https://adb-xxx.azuredatabricks.net"
```

#### Terraform Variables

```bash
# Override catalog name
export TF_VAR_catalog_name="my_catalog"

# Override environment
export TF_VAR_environment="dev"
```

### Remote Backend Configuration

For team collaboration, configure a remote backend:

**Step 1: Copy Example**

```bash
cd environments/dev
cp backend.tf.example backend.tf
```

**Step 2: Configure Backend**

Edit `backend.tf` with your storage details:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate<unique_id>"
    container_name       = "tfstate"
    key                  = "databricks/dev/terraform.tfstate"
  }
}
```

**Step 3: Initialize with Backend**

```bash
terraform init
```

If migrating from local state:

```bash
terraform init -migrate-state
```

---

## 📚 Examples

### Example 1: Basic Schema

```json
{
  "schema_name": "sales_data",
  "schema_comment": "Sales team data warehouse",
  "schema_properties": {
    "environment": "dev",
    "team": "sales",
    "purpose": "reporting"
  },
  "group_name": "sales_team",
  "privileges": ["USE_SCHEMA", "SELECT"]
}
```

### Example 2: Engineering Schema with Write Access

```json
{
  "schema_name": "etl_pipelines",
  "schema_comment": "Data engineering ETL workspace",
  "schema_properties": {
    "environment": "prod",
    "team": "data_engineering",
    "purpose": "etl",
    "owner": "data-eng@company.com",
    "sla": "99.9",
    "backup_policy": "daily"
  },
  "group_name": "data_engineers",
  "privileges": [
    "USE_SCHEMA",
    "CREATE_TABLE",
    "SELECT",
    "MODIFY"
  ]
}
```

### Example 3: ML Experimentation Schema

```json
{
  "schema_name": "ml_experiments",
  "schema_comment": "Machine learning model experimentation",
  "schema_properties": {
    "environment": "dev",
    "team": "ml_ops",
    "purpose": "ml_experimentation",
    "cost_center": "ai_ml",
    "retention_days": "90"
  },
  "group_name": "ml_scientists",
  "privileges": [
    "USE_SCHEMA",
    "CREATE_TABLE",
    "CREATE_FUNCTION",
    "SELECT",
    "MODIFY"
  ]
}
```

---

## 🎯 Best Practices

### 1. Environment Isolation

- Maintain separate schemas for dev, test, and prod
- Use different catalogs for each environment when possible
- Test changes in dev before promoting to prod

### 2. Naming Conventions

- Use lowercase with underscores for schema names
- Use descriptive names that indicate purpose
- Include team or department in name when appropriate

Examples:
- `analytics_reporting`
- `sales_data_warehouse`
- `ml_feature_store`

### 3. Permission Management

- Follow principle of least privilege
- Grant only necessary permissions
- Use groups, not individual users
- Document why permissions are granted (in schema_comment)

### 4. Documentation

- Add meaningful comments to schema definitions
- Use schema properties for metadata
- Include owner contact information
- Document purpose and use cases

### 5. Version Control

- Commit all schema definitions to git
- Use meaningful commit messages
- Require code review for production changes
- Tag releases for production deployments

### 6. State Management

- Use remote backends for team collaboration
- Enable state locking to prevent conflicts
- Backup state files regularly
- Never manually edit state files

### 7. Testing

- Always run `terraform plan` before `apply`
- Test in dev environment first
- Validate schema names and groups exist
- Review outputs after apply

### 8. Production Deployments

- Require approval for prod changes
- Deploy during maintenance windows
- Have rollback plan ready
- Monitor for errors after deployment

For detailed best practices, see [REFERENCED_BEST_PRACTICES.md](REFERENCED_BEST_PRACTICES.md).

---

## 🔧 Troubleshooting

### Common Issues

#### Issue: Schema Already Exists

**Error**: `Schema <name> already exists in catalog <catalog>`

**Solution**:
1. Check if schema was manually created
2. Import existing schema:
   ```bash
   terraform import \
     'module.databricks_schema["schema_key"].databricks_schema.this' \
     'catalog_name.schema_name'
   ```

#### Issue: Group Not Found

**Error**: `Group <name> does not exist`

**Solution**:
1. Verify group name is correct
2. Create group in Databricks workspace
3. Update JSON file with correct group name

#### Issue: Permission Denied

**Error**: `Permission denied to create schema`

**Solution**:
1. Verify authentication credentials
2. Check user/SP has CREATE SCHEMA privilege on catalog
3. Verify user is workspace admin or has necessary grants

#### Issue: Authentication Failed

**Error**: `Authentication failed`

**Solution**:
1. Check environment variables are set
2. Verify token hasn't expired
3. Test authentication with Databricks CLI
4. For Azure AD, verify all 4 ARM_* variables are set

#### Issue: JSON Parse Error

**Error**: `Invalid JSON in schema definition`

**Solution**:
1. Validate JSON syntax (use `jq` or online validator)
2. Check for trailing commas
3. Ensure quotes are properly closed
4. Verify UTF-8 encoding

### Getting Help

1. **Check Logs**: Review Terraform output for detailed error messages
2. **Validate Configuration**: Run `terraform validate`
3. **Check State**: Run `terraform state list` to see managed resources
4. **Documentation**: Refer to [Databricks Terraform Provider docs](https://registry.terraform.io/providers/databricks/databricks/latest/docs)
5. **Community**: Ask in Databricks Community or HashiCorp Discuss

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

### Reporting Issues

- Use GitHub Issues to report bugs
- Include Terraform and provider versions
- Provide minimal reproduction steps
- Include relevant error messages

### Submitting Changes

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Code Style

- Follow Terraform style guide
- Run `terraform fmt` before committing
- Add comments for complex logic
- Update documentation as needed

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- HashiCorp for Terraform
- Databricks for Unity Catalog
- Community contributors

**Built with ❤️ using Terraform and Databricks Unity Catalog**

**Version**: 1.0.0  
**Last Updated**: November 7, 2025


