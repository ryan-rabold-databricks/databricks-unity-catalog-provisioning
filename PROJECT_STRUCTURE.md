# Project Structure Guide

This document describes the purpose and responsibility of each folder and file in the project.

---

## 📁 Root Directory

```
databricks-unity-catalog-provisioning/
```

The root directory contains the main project and documentation files.

### Root Files

| File | Responsibility |
|------|----------------|
| `README.md` | **Main documentation** - Project overview, quick start, usage instructions, and examples |
| `REFERENCED_BEST_PRACTICES.md` | **Best practices guide** - 15+ sections covering Terraform and Databricks best practices with references |
| `PROJECT_STRUCTURE.md` | **This file** - Describes the purpose of each directory and file |
| `.gitignore` | **Version control configuration** - Defines files to exclude from git (secrets, state files, etc.) |

---

## 📦 Modules Directory

```
modules/
├── databricks-schema/
└── databricks-permissions/
```

**Purpose**: Contains reusable Terraform modules that can be called from any environment configuration.

**Responsibility**: Provides encapsulated, tested, and reusable infrastructure components.

### Module: databricks-schema

```
modules/databricks-schema/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── README.md
```

**Purpose**: Creates Databricks Unity Catalog schemas with custom properties.

| File | Responsibility |
|------|----------------|
| `main.tf` | **Resource definition** - Defines the `databricks_schema` resource and its configuration |
| `variables.tf` | **Input interface** - Declares input variables (catalog_name, schema_name, properties, etc.) |
| `outputs.tf` | **Output interface** - Exposes schema ID, name, and full name for use by other modules |
| `versions.tf` | **Provider requirements** - Specifies required Terraform and provider versions |
| `README.md` | **Module documentation** - Usage instructions, examples, and input/output reference |

**Key Responsibilities**:
- Create Unity Catalog schemas
- Set schema comments
- Configure schema properties (metadata)
- Return schema identifiers for reference

### Module: databricks-permissions

```
modules/databricks-permissions/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── README.md
```

**Purpose**: Grants permissions to Databricks groups on Unity Catalog schemas.

| File | Responsibility |
|------|----------------|
| `main.tf` | **Resource definition** - Defines the `databricks_grant` resource for schema permissions |
| `variables.tf` | **Input interface** - Declares input variables (schema name, group, privileges) |
| `outputs.tf` | **Output interface** - Exposes granted permissions and principal information |
| `versions.tf` | **Provider requirements** - Specifies required Terraform and provider versions |
| `README.md` | **Module documentation** - Usage instructions, privilege options, and examples |

**Key Responsibilities**:
- Grant privileges to groups on schemas
- Support multiple privilege types (USE_SCHEMA, SELECT, CREATE_TABLE, etc.)
- Manage permission lifecycles
- Return granted permissions for audit

---

## 🌍 Environments Directory

```
environments/
├── dev/
├── test/
└── prod/
```

**Purpose**: Contains environment-specific Terraform configurations for dev, test, and production.

**Responsibility**: Orchestrates the creation of schemas and permissions by calling reusable modules with environment-specific data.

### Environment Structure (dev, test, prod)

Each environment directory has the same structure:

```
environments/dev/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── backend.tf.example
└── README.md
```

| File | Responsibility |
|------|----------------|
| `main.tf` | **Main configuration** - Loads schema JSON files, calls modules, and orchestrates resource creation |
| `variables.tf` | **Variable definitions** - Defines input variables specific to this environment |
| `outputs.tf` | **Output definitions** - Aggregates outputs from modules for environment-level reporting |
| `terraform.tfvars.example` | **Configuration template** - Example variable values (copy to `terraform.tfvars` and customize) |
| `backend.tf.example` | **State management template** - Example remote backend configuration (Azure, S3, Terraform Cloud) |
| `README.md` | **Environment documentation** - Environment-specific usage instructions and quick start |

**Key Responsibilities**:
- **main.tf**:
  - Load schema JSON files using `fileset()` and `jsondecode()`
  - Transform JSON data into module inputs
  - Call `databricks-schema` module for each schema
  - Call `databricks-permissions` module for each schema
  - Manage dependencies between modules

- **variables.tf**:
  - Define `environment` variable (with validation)
  - Define `catalog_name` variable (with validation)
  - Define authentication variables
  - Define tags for resource organization

- **outputs.tf**:
  - Expose created schemas
  - Expose granted permissions
  - Provide summary information
  - Enable integration with other systems

### Environment-Specific Details

#### Development (dev/)

**Purpose**: Development and experimentation environment

**Characteristics**:
- Default catalog: `dev_catalog`
- More permissive privileges
- Rapid iteration
- Can be easily recreated

#### Test (test/)

**Purpose**: Integration and validation testing

**Characteristics**:
- Default catalog: `test_catalog`
- Mirrors production structure
- Restricted write access
- Automated testing friendly

#### Production (prod/)

**Purpose**: Live production environment

**Characteristics**:
- Default catalog: `prod_catalog`
- Minimal privileges
- High availability
- Strong backup policies

---

## 📄 Schemas Directory

```
schemas/
├── dev/
├── test/
└── prod/
```

**Purpose**: Contains JSON files that define Unity Catalog schemas for each environment.

**Responsibility**: Provides data-driven schema definitions that are loaded by environment configurations.

### Schema Files

Each JSON file represents a single schema:

```json
{
  "schema_name": "string",
  "schema_comment": "string",
  "schema_properties": {},
  "group_name": "string",
  "privileges": []
}
```

**Key Responsibilities**:
- Define schema names and descriptions
- Specify schema metadata (properties)
- Define which group gets access
- Specify what privileges to grant

**Benefits of JSON-based Definitions**:
- Non-technical users can add schemas
- Version controlled
- Easy to review in pull requests
- Separate code from data
- Environment-specific configurations

### Example Files

| File | Purpose |
|------|---------|
| `dev/analytics-team-schema.json` | Analytics team development workspace |
| `test/analytics-team-schema.json` | Analytics testing environment |
| `prod/analytics-team-schema.json` | Analytics production environment |

---

## 📚 Examples Directory

```
examples/
└── complete/
```

**Purpose**: Provides working examples of how to use the modules and configurations.

**Responsibility**: Demonstrates best practices and common use cases.

### Complete Example

```
examples/complete/
└── README.md
```

**Purpose**: Full end-to-end example showing how to use the entire system.

**Contents** (to be added):
- Sample schema definitions
- Complete configuration
- Step-by-step instructions
- Expected outputs

---

## 📖 Docs Directory

```
docs/
```

**Purpose**: Contains additional documentation beyond the main README.

**Responsibility**: Houses detailed guides, tutorials, and reference materials.

**Future Content** (planned):
- Architecture diagrams
- Troubleshooting guides
- Migration guides
- Integration examples
- Video tutorials

---

## 🔄 Data Flow

### How the Components Work Together

```
1. User creates JSON file
   ↓
schemas/dev/my-schema.json

2. Environment config loads JSON
   ↓
environments/dev/main.tf (fileset + jsondecode)

3. Data passed to modules
   ↓
modules/databricks-schema
modules/databricks-permissions

4. Resources created in Databricks
   ↓
Unity Catalog Schema + Permissions

5. State updated
   ↓
terraform.tfstate

6. Outputs available
   ↓
terraform output (schemas, permissions)
```

---

## 🎯 Responsibilities Summary

### Configuration Layer (environments/)

**What**: Orchestrates resource creation  
**How**: Loads data, calls modules  
**When**: On terraform apply  
**Where**: Environment-specific directories

### Module Layer (modules/)

**What**: Creates actual resources  
**How**: Defines Databricks resources  
**When**: Called by environment configs  
**Where**: Reusable module directories

### Data Layer (schemas/)

**What**: Defines what to create  
**How**: JSON files  
**When**: Loaded at runtime  
**Where**: Environment-specific schema directories

### Documentation Layer (root docs)

**What**: Guides and references  
**How**: Markdown files  
**When**: Read by users  
**Where**: Root directory and docs/

---

## 🔐 File Security

### Never Commit

These files should **never** be committed to git (already in `.gitignore`):

| File Pattern | Reason |
|--------------|--------|
| `*.tfvars` | May contain sensitive data |
| `*.tfstate*` | Contains all resource details |
| `backend.tf` | May contain backend credentials |
| `.terraform/` | Provider binaries and cache |
| `.env*` | Environment variables |

### Always Commit

These files should **always** be committed:

| File Pattern | Reason |
|--------------|--------|
| `*.tf` | Infrastructure code |
| `*.json` (in schemas/) | Schema definitions |
| `*.md` | Documentation |
| `*.example` | Templates for users |
| `.gitignore` | Git configuration |

---

## 📊 File Ownership

### Who Modifies What

| File Type | Modified By | Review Required |
|-----------|-------------|-----------------|
| `modules/**/*.tf` | Infrastructure team | Yes (code review) |
| `environments/**/main.tf` | Infrastructure team | Yes (code review) |
| `schemas/**/*.json` | Schema requesters | Yes (PR review) |
| `*.md` | Anyone | Yes (PR review) |
| `terraform.tfvars` | Operations team | Not in git |

---

## 🔄 Typical Workflow

### Adding a New Schema

1. **User**: Creates JSON file in `schemas/dev/`
2. **Git**: Commits and pushes to branch
3. **CI/CD**: Validates JSON syntax (optional)
4. **Reviewer**: Reviews PR for schema definition
5. **User**: Merges PR to main
6. **Operations**: Runs terraform in `environments/dev/`
7. **Terraform**: Loads JSON from `schemas/dev/`
8. **Terraform**: Calls `modules/databricks-schema`
9. **Terraform**: Calls `modules/databricks-permissions`
10. **Databricks**: Schema created with permissions
11. **Terraform**: Updates state and outputs results

---

## 🎓 Learning Path

### For New Users

1. Start with root `README.md` - Understand the project
2. Read `REFERENCED_BEST_PRACTICES.md` - Learn best practices
3. Review `schemas/README.md` - Understand schema definitions
4. Look at example files in `schemas/dev/` - See real examples
5. Read environment `README.md` - Understand deployment process
6. Review `PROJECT_STRUCTURE.md` (this file) - Understand organization

### For Developers

1. Review module READMEs in `modules/` - Understand building blocks
2. Study `environments/dev/main.tf` - See how modules are called
3. Read `REFERENCED_BEST_PRACTICES.md` - Learn coding standards
4. Review `.gitignore` - Understand security practices

---

## 🔍 Finding Information

### "Where do I...?"

| Task | Location |
|------|----------|
| Add a new schema | Create JSON in `schemas/{env}/` |
| Change schema structure | Modify `modules/databricks-schema/` |
| Add new environment | Copy `environments/dev/` to `environments/new/` |
| Update documentation | Modify relevant `README.md` or `*.md` file |
| Configure authentication | Set environment variables or `terraform.tfvars` |
| Set up remote state | Copy and edit `backend.tf.example` |
| Find examples | Look in `schemas/*/` and `examples/` |
| Troubleshoot | Check main `README.md` troubleshooting section |

---

## 📝 File Naming Conventions

### Terraform Files

- `main.tf` - Primary configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `versions.tf` - Provider versions
- `backend.tf` - Backend configuration
- `locals.tf` - Local values (if complex)

### Schema Files

- `{descriptive-name}.json` - One schema per file
- Lowercase with hyphens
- Descriptive and meaningful
- Examples: `analytics-team.json`, `ml-experiments.json`

### Documentation Files

- `README.md` - Main documentation
- `{TOPIC}.md` - Specific topic (uppercase)
- Examples: `PROJECT_STRUCTURE.md`, `DEPLOYMENT_WALKTHROUGH.md`

---

**This document last updated**: November 7, 2025  
**Version**: 1.0.0


