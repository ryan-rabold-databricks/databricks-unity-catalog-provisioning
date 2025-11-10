# Development Environment

This directory contains the Terraform configuration for the **development** environment.

## Directory Contents

- `main.tf` - Main configuration that loads schema definitions and creates resources
- `variables.tf` - Input variable definitions
- `outputs.tf` - Output value definitions
- `terraform.tfvars.example` - Example variable values
- `backend.tf.example` - Example remote state configuration

## Quick Start

### 1. Configure Variables

```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

### 2. Set Authentication

```bash
# Option A: Use environment variables
export DATABRICKS_HOST="https://adb-xxx.azuredatabricks.net"
export DATABRICKS_TOKEN="your-token"

# Option B: Use Databricks CLI profile
export DATABRICKS_CONFIG_PROFILE="your-profile"

# Option C: Use Azure AD Service Principal
export ARM_CLIENT_ID="xxx"
export ARM_CLIENT_SECRET="xxx"
export ARM_TENANT_ID="xxx"
export DATABRICKS_HOST="https://adb-xxx.azuredatabricks.net"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan Changes

```bash
terraform plan
```

### 5. Apply Changes

```bash
terraform apply
```

## Adding a New Schema

To add a new schema to the development environment:

1. Create a JSON file in `../../schemas/dev/`:

```bash
cat > ../../schemas/dev/my-new-schema.json << 'EOF'
{
  "schema_name": "my_new_schema",
  "schema_comment": "My new schema for development",
  "schema_properties": {
    "environment": "dev",
    "team": "my_team",
    "purpose": "data_processing"
  },
  "group_name": "my_databricks_group",
  "privileges": [
    "USE_SCHEMA",
    "CREATE_TABLE",
    "SELECT"
  ]
}
EOF
```

2. Run Terraform to create the schema:

```bash
terraform plan
terraform apply
```

## Schema File Format

Each schema is defined in a JSON file with the following structure:

```json
{
  "schema_name": "string",
  "schema_comment": "string",
  "schema_properties": {
    "key": "value"
  },
  "group_name": "string",
  "privileges": ["array", "of", "privileges"]
}
```

## Outputs

After applying, you can view the created resources:

```bash
# View all outputs
terraform output

# View specific output
terraform output schemas
```

## State Management

For team collaboration, configure a remote backend:

1. Copy backend configuration: `cp backend.tf.example backend.tf`
2. Update with your storage details
3. Uncomment the backend block in `main.tf`
4. Run: `terraform init -migrate-state`

## Cleanup

To destroy all resources in this environment:

```bash
terraform destroy
```

**⚠️ Warning**: This will delete all schemas and permissions managed by this configuration.


