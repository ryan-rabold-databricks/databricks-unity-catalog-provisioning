# Schema Definitions

This directory contains JSON files that define Unity Catalog schemas for each environment.

## Directory Structure

```
schemas/
├── dev/          # Development environment schemas
├── test/         # Test environment schemas
└── prod/         # Production environment schemas
```

## Schema File Format

Each schema is defined in a JSON file with the following structure:

```json
{
  "schema_name": "string",
  "schema_comment": "string",
  "schema_properties": {
    "environment": "dev|test|prod",
    "team": "string",
    "purpose": "string",
    "owner": "string"
  },
  "group_name": "string",
  "privileges": ["array", "of", "privileges"]
}
```

## Creating a New Schema

### Step 1: Choose Environment

Decide which environment the schema should be created in:
- `dev/` - Development and experimentation
- `test/` - Testing and validation
- `prod/` - Production use

### Step 2: Create JSON File

Create a new `.json` file in the appropriate directory:

```bash
nano schemas/dev/my-schema.json
```

### Step 3: Define Schema

Fill in the schema definition:

```json
{
  "schema_name": "my_team_data",
  "schema_comment": "My team's data warehouse",
  "schema_properties": {
    "environment": "dev",
    "team": "my_team",
    "purpose": "data_analysis",
    "owner": "myteam@company.com"
  },
  "group_name": "my_databricks_group",
  "privileges": [
    "USE_SCHEMA",
    "CREATE_TABLE",
    "SELECT"
  ]
}
```

### Step 4: Apply with Terraform

```bash
cd ../environments/dev
terraform plan
terraform apply
```

## Field Descriptions

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `schema_name` | string | Name of the schema (lowercase with underscores) |
| `schema_comment` | string | Description of the schema's purpose |
| `schema_properties` | object | Key-value pairs for metadata |
| `group_name` | string | Databricks group to grant permissions to |
| `privileges` | array | List of permissions to grant |

### Schema Properties

Recommended properties to include:

| Property | Description | Example |
|----------|-------------|---------|
| `environment` | Environment name | `"dev"`, `"test"`, `"prod"` |
| `team` | Owning team | `"analytics"`, `"engineering"` |
| `purpose` | Use case | `"reporting"`, `"etl"`, `"ml"` |
| `owner` | Contact email | `"team@company.com"` |
| `cost_center` | For cost allocation | `"analytics"` |
| `sla` | Service level agreement | `"99.9"` (optional, for prod) |
| `backup_policy` | Backup frequency | `"daily"` (optional, for prod) |

### Available Privileges

Common privilege combinations:

**Read-Only Access**:
```json
"privileges": ["USE_SCHEMA", "SELECT"]
```

**Analyst Access**:
```json
"privileges": ["USE_SCHEMA", "CREATE_TABLE", "SELECT"]
```

**Full Access**:
```json
"privileges": ["USE_SCHEMA", "CREATE_TABLE", "SELECT", "MODIFY"]
```

**All Privileges** (use cautiously):
```json
"privileges": ["ALL_PRIVILEGES"]
```

## Naming Conventions

### Schema Names

- Use lowercase letters
- Use underscores for spaces
- Be descriptive but concise
- Include team or purpose

**Good Examples**:
- `analytics_reporting`
- `sales_data_warehouse`
- `ml_feature_store`
- `customer_360`

**Avoid**:
- `schema1` (not descriptive)
- `MySchema` (use lowercase)
- `my-schema` (use underscores, not hyphens)

### File Names

- Match the schema name
- Use `.json` extension
- Use descriptive names

**Examples**:
- `analytics-reporting.json`
- `sales-data-warehouse.json`
- `ml-feature-store.json`

## Environment-Specific Schemas

### Development (`dev/`)

- Experimentation and testing
- More permissive privileges
- Shorter retention policies
- Can be recreated easily

**Recommended Properties**:
```json
{
  "schema_properties": {
    "environment": "dev",
    "retention_days": "30",
    "backup_policy": "none"
  },
  "privileges": ["USE_SCHEMA", "CREATE_TABLE", "SELECT", "MODIFY"]
}
```

### Test (`test/`)

- Integration and validation testing
- Restricted write access
- Mirror of production structure
- Automated testing

**Recommended Properties**:
```json
{
  "schema_properties": {
    "environment": "test",
    "retention_days": "90",
    "backup_policy": "weekly"
  },
  "privileges": ["USE_SCHEMA", "CREATE_TABLE", "SELECT"]
}
```

### Production (`prod/`)

- Live production data
- Minimal privileges
- Strong backup policies
- High availability

**Recommended Properties**:
```json
{
  "schema_properties": {
    "environment": "prod",
    "sla": "99.9",
    "backup_policy": "daily",
    "retention_years": "7",
    "compliance": "GDPR,CCPA"
  },
  "privileges": ["USE_SCHEMA", "SELECT"]
}
```

## Examples

See the existing JSON files in each directory for complete examples:

- `dev/analytics-team-schema.json` - Analytics team development
- `dev/data-engineering-schema.json` - Data engineering pipelines
- `dev/ml-experimentation-schema.json` - ML experimentation
- `test/analytics-team-schema.json` - Analytics testing
- `prod/analytics-team-schema.json` - Analytics production

## Best Practices

1. **One schema per file** - Each JSON file defines a single schema
2. **Descriptive names** - Use clear, meaningful names
3. **Complete metadata** - Fill in all recommended properties
4. **Least privilege** - Grant only necessary permissions
5. **Version control** - Commit all changes to git
6. **Code review** - Have changes reviewed before merging
7. **Test first** - Create in dev, test, then promote to prod
8. **Documentation** - Use meaningful comments and properties

## Validation

Before applying, validate your JSON:

```bash
# Check JSON syntax
jq empty schemas/dev/my-schema.json

# Pretty print
jq . schemas/dev/my-schema.json
```

## Troubleshooting

### JSON Syntax Errors

Use a JSON validator:
```bash
cat schemas/dev/my-schema.json | jq .
```

### Schema Already Exists

If the schema already exists in Databricks:
1. Remove or rename the JSON file, or
2. Import the existing schema into Terraform state

### Group Not Found

Verify the group exists in your Databricks workspace:
1. Go to Settings → Identity and access → Groups
2. Create the group if it doesn't exist
3. Update the JSON with the correct group name

## Need Help?

- Review the main [README.md](../README.md)
- Check [REFERENCED_BEST_PRACTICES.md](../REFERENCED_BEST_PRACTICES.md)
- Look at existing examples in this directory
- Open an issue on GitHub

