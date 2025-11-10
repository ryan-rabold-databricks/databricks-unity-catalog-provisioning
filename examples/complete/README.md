# Complete Example

This directory will contain a complete, working example of how to use the Databricks Unity Catalog Provisioning accelerator.

## Example Scenario

**Organization**: AcmeCorp  
**Requirement**: Provision schemas for Analytics, Data Engineering, and ML teams  
**Environments**: Dev, Test, Prod  
**Approach**: Progressive promotion from dev → test → prod

## Step-by-Step Guide

### 1. Initial Setup

```bash
# Clone the repository
git clone <repo-url>
cd databricks-unity-catalog-provisioning

# Navigate to dev environment
cd environments/dev
```

### 2. Configure Authentication

```bash
# Set up Databricks authentication
export DATABRICKS_HOST="https://adb-xxx.azuredatabricks.net"
export DATABRICKS_TOKEN="your-token"

# Or use Databricks CLI profile
export DATABRICKS_CONFIG_PROFILE="acmecorp-dev"
```

### 3. Configure Variables

```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your catalog name
nano terraform.tfvars
```

Set:
```hcl
catalog_name = "acmecorp_dev"
environment  = "dev"
```

### 4. Create Schema Definitions

The analytics team needs a schema in dev:

**Analytics Team** (`../../schemas/dev/analytics-team.json`):
```json
{
  "schema_name": "analytics_workspace",
  "schema_comment": "Analytics team workspace for reporting and dashboards",
  "schema_properties": {
    "environment": "dev",
    "team": "analytics",
    "purpose": "reporting",
    "owner": "analytics@acmecorp.com"
  },
  "group_name": "acmecorp_analytics",
  "privileges": ["USE_SCHEMA", "CREATE_TABLE", "SELECT", "MODIFY"]
}
```

**Note:** You can add more schemas by creating additional JSON files in the `schemas/dev/` directory.

### 5. Initialize and Apply

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Expected output:
# Plan: 2 to add, 0 to change, 0 to destroy.
# (1 schema + 1 permission grant)

# Apply the configuration
terraform apply
```

### 6. Verify Creation

```bash
# View outputs
terraform output

# Expected output:
# catalog_name = "acmecorp_dev"
# environment = "dev"
# schemas = {
#   "analytics-team" = {
#     "schema_full_name" = "acmecorp_dev.analytics_workspace"
#     "schema_id" = "acmecorp_dev.analytics_workspace"
#     "schema_name" = "analytics_workspace"
#   }
#   ...
# }
```

### 7. Test in Databricks

Login to Databricks and verify:

```sql
-- Show created schemas
SHOW SCHEMAS IN acmecorp_dev;

-- Verify permissions
SHOW GRANTS ON SCHEMA acmecorp_dev.analytics_workspace;

-- Test access (as member of analytics group)
USE CATALOG acmecorp_dev;
USE SCHEMA analytics_workspace;
CREATE TABLE test_table (id INT, name STRING);
SELECT * FROM test_table;
```

### 8. Promote to Test

Once validated in dev, promote to test:

```bash
# Copy schema definition to test
cp ../../schemas/dev/analytics-team.json ../../schemas/test/

# Update environment in each file (change "dev" to "test")
sed -i 's/"environment": "dev"/"environment": "test"/g' ../../schemas/test/*.json

# Navigate to test environment
cd ../test

# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Set catalog_name = "acmecorp_test"

# Apply
terraform init
terraform plan
terraform apply
```

### 9. Promote to Production

After successful testing, promote to prod:

```bash
# Copy schema definition to prod
cp ../../schemas/test/analytics-team.json ../../schemas/prod/

# Update environment and reduce privileges for prod
sed -i 's/"environment": "test"/"environment": "prod"/g' ../../schemas/prod/*.json

# For analytics team in prod, reduce to read-only
# Edit ../../schemas/prod/analytics-team.json:
# "privileges": ["USE_SCHEMA", "SELECT"]

# Navigate to prod environment
cd ../prod

# Configure
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Set catalog_name = "acmecorp_prod"

# Apply with extra caution
terraform init
terraform plan  # Review carefully!
terraform apply
```

## Expected Results

After completing all steps, you'll have:

### Development Environment
- **Catalog**: `acmecorp_dev`
- **Schemas**:
  - `analytics_workspace` (full access for analytics group)

### Test Environment
- **Catalog**: `acmecorp_test`
- **Schemas**: Same as dev with test-specific configurations

### Production Environment
- **Catalog**: `acmecorp_prod`
- **Schemas**: Same names but with restricted permissions

## Common Variations

### Add a New Team

If a new team needs a schema:

1. Create JSON file: `schemas/dev/new-team.json`
2. Run: `terraform apply` in `environments/dev/`
3. Schema automatically created

### Modify Permissions

To add MODIFY privilege to analytics team:

1. Edit: `schemas/dev/analytics-team.json`
2. Add `"MODIFY"` to privileges array
3. Run: `terraform apply`

### Remove a Schema

⚠️ **Caution**: This deletes the schema and all its data!

1. Delete: `schemas/dev/team-name.json`
2. Run: `terraform apply`
3. Confirm destruction when prompted

## Integration Examples

### With CI/CD

```yaml
# .github/workflows/terraform.yml
name: Terraform

on:
  pull_request:
    paths:
      - 'schemas/**'
      - 'environments/**'

jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - run: terraform init
        working-directory: environments/dev
      - run: terraform plan
        working-directory: environments/dev
```

### With Databricks CLI

```bash
# List schemas after creation
databricks unity-catalog schemas list \
  --catalog-name acmecorp_dev

# Check permissions
databricks unity-catalog grants list \
  --full-name acmecorp_dev.analytics_workspace
```

### With Python

```python
from databricks import sql

# Connect and query
connection = sql.connect(
    server_hostname="adb-xxx.azuredatabricks.net",
    http_path="/sql/1.0/warehouses/...",
    access_token="..."
)

cursor = connection.cursor()
cursor.execute("SHOW SCHEMAS IN acmecorp_dev")
print(cursor.fetchall())
```

## Troubleshooting

### Issue: "Catalog not found"

**Solution**: Ensure the catalog exists in your workspace:
```sql
SHOW CATALOGS;
CREATE CATALOG IF NOT EXISTS acmecorp_dev;
```

### Issue: "Group not found"

**Solution**: Create the group in Databricks:
1. Settings → Identity and access → Groups
2. Click "Create group"
3. Add group members

### Issue: "Permission denied"

**Solution**: Verify your credentials have CREATE SCHEMA privilege:
```sql
SHOW GRANTS ON CATALOG acmecorp_dev;
```

## Next Steps

1. **Set up remote backend** for team collaboration
2. **Add CI/CD pipeline** for automated deployments
3. **Create monitoring** for schema usage
4. **Document** team-specific requirements
5. **Train users** on self-service schema requests

## Resources

- [Main README](../../README.md)
- [Best Practices](../../REFERENCED_BEST_PRACTICES.md)
- [Project Structure](../../PROJECT_STRUCTURE.md)
- [Schema Guide](../../schemas/README.md)

---

**Last Updated**: November 7, 2025


