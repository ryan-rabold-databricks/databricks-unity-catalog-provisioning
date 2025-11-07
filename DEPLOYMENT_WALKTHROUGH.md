# Step-by-Step Deployment Walkthrough

This guide walks you through deploying schemas to your Databricks dev environment.

---

## Prerequisites Checklist

Before starting, ensure you have:
- [ ] Terraform installed (v1.0+)
- [ ] Access to a Databricks workspace with Unity Catalog
- [ ] A catalog where you have CREATE SCHEMA privileges
- [ ] Databricks authentication (token or CLI profile)
- [ ] The groups referenced in your schemas exist in Databricks

---

## Step 1: Navigate to Dev Environment

```bash
cd /Users/ryan.rabold/Providence/databricks-unity-catalog-provisioning/environments/dev
```

---

## Step 2: Configure Variables

### Copy the Example File

```bash
cp terraform.tfvars.example terraform.tfvars
```

### Edit Your Configuration

```bash
nano terraform.tfvars
# or use your preferred editor: code terraform.tfvars
```

### Set Your Values

```hcl
# terraform.tfvars
catalog_name = "your_dev_catalog"  # Replace with your actual catalog name
environment  = "dev"

# Optional: if not using environment variables
# databricks_host  = "https://adb-xxx.azuredatabricks.net"
# databricks_token = "dapi..."  # Better to use env vars for security
```

**Important:** Use a test or dev catalog, NOT your production catalog!

---

## Step 3: Set Up Authentication

Choose ONE of these methods:

### Option A: Environment Variables (Recommended)

```bash
export DATABRICKS_HOST="https://adb-xxx.azuredatabricks.net"
export DATABRICKS_TOKEN="dapi..."
```

### Option B: Databricks CLI Profile

```bash
export DATABRICKS_CONFIG_PROFILE="your-profile-name"
```

### Option C: Azure Service Principal

```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="your-tenant-id"
export DATABRICKS_HOST="https://adb-xxx.azuredatabricks.net"
```

### Verify Authentication

```bash
# Test connection (requires databricks CLI)
databricks catalogs list

# Or test with curl
curl -X GET \
  -H "Authorization: Bearer $DATABRICKS_TOKEN" \
  "$DATABRICKS_HOST/api/2.1/unity-catalog/catalogs"
```

---

## Step 4: Verify Catalog Exists

Before proceeding, ensure your catalog exists and you have permissions:

```sql
-- Run in Databricks SQL Editor or notebook

-- Check if catalog exists
SHOW CATALOGS;

-- Create catalog if it doesn't exist
CREATE CATALOG IF NOT EXISTS your_dev_catalog;

-- Grant yourself permissions
GRANT CREATE SCHEMA ON CATALOG your_dev_catalog TO `your.email@company.com`;
GRANT USE CATALOG ON CATALOG your_dev_catalog TO `your.email@company.com`;

-- Verify permissions
SHOW GRANTS ON CATALOG your_dev_catalog;
```

---

## Step 5: Verify Groups Exist

Check that the groups referenced in your schemas exist:

```bash
# List current schemas to see what groups are needed
cd ../..
for file in schemas/dev/*.json; do 
  echo "$(basename $file): $(jq -r .group_name $file)"
done
```

In Databricks:
1. Go to **Settings** → **Identity and access** → **Groups**
2. Verify these groups exist:
   - `analytics_group`
   - `data_engineering_group`
   - `ml_group`
3. Create any missing groups

---

## Step 6: Initialize Terraform

```bash
cd /Users/ryan.rabold/Providence/databricks-unity-catalog-provisioning/environments/dev

# Initialize Terraform (downloads provider plugins)
terraform init
```

**Expected Output:**
```
Initializing modules...
- databricks_permissions in ../../modules/databricks-permissions
- databricks_schema in ../../modules/databricks-schema

Initializing the backend...

Initializing provider plugins...
- Finding databricks/databricks versions matching "~> 1.0"...
- Installing databricks/databricks v1.x.x...

Terraform has been successfully initialized!
```

**If this fails:** See troubleshooting section at the end.

---

## Step 7: Validate Configuration

```bash
# Validate Terraform syntax and configuration
terraform validate
```

**Expected Output:**
```
Success! The configuration is valid.
```

---

## Step 8: Review What Will Be Created

```bash
# Run plan to see what Terraform will create
terraform plan
```

**Expected Output:**
```
Terraform used the selected providers to generate the following execution plan. 
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.databricks_schema["analytics-team-schema"].databricks_schema.this will be created
  + resource "databricks_schema" "this" {
      + catalog_name = "your_dev_catalog"
      + comment      = "Analytics team schema for exploratory data analysis and reporting"
      + id           = (known after apply)
      + name         = "analytics_team"
      + properties   = {
          + "cost_center" = "analytics"
          + "environment" = "dev"
          + "owner"       = "analytics-team@company.com"
          + "purpose"     = "data_analysis"
          + "team"        = "analytics"
        }
    }

  # module.databricks_permissions["analytics-team-schema"].databricks_grants.this will be created
  + resource "databricks_grants" "this" {
      + schema = "your_dev_catalog.analytics_team"
      + grant {
          + principal  = "analytics_group"
          + privileges = [
              + "CREATE_TABLE",
              + "MODIFY",
              + "SELECT",
              + "USE_SCHEMA",
            ]
        }
    }

  # ... (similar output for other schemas) ...

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + catalog_name = "your_dev_catalog"
  + environment  = "dev"
  + schemas      = {
      + analytics-team-schema = {
          + schema_full_name = "your_dev_catalog.analytics_team"
          + schema_id        = (known after apply)
          + schema_name      = "analytics_team"
        }
      # ... more schemas ...
    }
```

### Review Checklist

Carefully review the plan and verify:

- [ ] **Catalog name** is correct (your dev catalog, not prod!)
- [ ] **Schema names** match what you expect (3 schemas)
- [ ] **Group names** are correct
- [ ] **Privileges** are appropriate for dev environment
- [ ] **Properties** are set correctly
- [ ] **Plan shows:** `6 to add, 0 to change, 0 to destroy`
- [ ] **No unexpected deletions** (0 to destroy)

**If anything looks wrong, STOP and fix it before applying!**

---

## Step 9: Save the Plan (Optional but Recommended)

```bash
# Save plan to a file for review
terraform plan -out=tfplan

# Review the saved plan
terraform show tfplan

# Or save to JSON for detailed inspection
terraform show -json tfplan | jq . > plan.json
```

---

## Step 10: Apply the Configuration

**⚠️ WARNING:** This will create resources in your Databricks workspace!

```bash
# Apply the configuration
terraform apply
```

Terraform will show you the plan again and prompt:

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```

Type `yes` and press Enter.

**Expected Output:**
```
module.databricks_schema["analytics-team-schema"].databricks_schema.this: Creating...
module.databricks_schema["data-engineering-schema"].databricks_schema.this: Creating...
module.databricks_schema["ml-experimentation-schema"].databricks_schema.this: Creating...
module.databricks_schema["analytics-team-schema"].databricks_schema.this: Creation complete after 2s
module.databricks_schema["data-engineering-schema"].databricks_schema.this: Creation complete after 2s
module.databricks_schema["ml-experimentation-schema"].databricks_schema.this: Creation complete after 3s
module.databricks_permissions["analytics-team-schema"].databricks_grants.this: Creating...
module.databricks_permissions["data-engineering-schema"].databricks_grants.this: Creating...
module.databricks_permissions["ml-experimentation-schema"].databricks_grants.this: Creating...
module.databricks_permissions["analytics-team-schema"].databricks_grants.this: Creation complete after 1s
module.databricks_permissions["data-engineering-schema"].databricks_grants.this: Creation complete after 1s
module.databricks_permissions["ml-experimentation-schema"].databricks_grants.this: Creation complete after 1s

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

catalog_name = "your_dev_catalog"
environment = "dev"
schemas = {
  "analytics-team-schema" = {
    "schema_full_name" = "your_dev_catalog.analytics_team"
    "schema_id" = "your_dev_catalog.analytics_team"
    "schema_name" = "analytics_team"
  }
  "data-engineering-schema" = {
    "schema_full_name" = "your_dev_catalog.data_engineering"
    "schema_id" = "your_dev_catalog.data_engineering"
    "schema_name" = "data_engineering"
  }
  "ml-experimentation-schema" = {
    "schema_full_name" = "your_dev_catalog.ml_experimentation"
    "schema_id" = "your_dev_catalog.ml_experimentation"
    "schema_name" = "ml_experimentation"
  }
}
```

**Success! Your schemas have been created!** 🎉

---

## Step 11: Verify in Databricks UI

1. **Open Databricks Workspace**
2. **Navigate to Catalog**
   - Click on **Catalog** in the left sidebar
   - Find your catalog: `your_dev_catalog`
3. **Verify Schemas**
   - You should see 3 schemas:
     - `analytics_team`
     - `data_engineering`
     - `ml_experimentation`
4. **Check Schema Properties**
   - Click on a schema
   - Click the **Details** tab
   - Verify properties are set correctly
5. **Check Permissions**
   - Click on a schema
   - Click the **Permissions** tab
   - Verify groups have correct privileges

---

## Step 12: Verify with SQL

Open a Databricks notebook or SQL editor:

```sql
-- Show all schemas in your catalog
SHOW SCHEMAS IN your_dev_catalog;

-- Check specific schema details
DESCRIBE SCHEMA EXTENDED your_dev_catalog.analytics_team;

-- View schema properties
SELECT *
FROM system.information_schema.schemata
WHERE schema_name = 'analytics_team';

-- Verify permissions
SHOW GRANTS ON SCHEMA your_dev_catalog.analytics_team;

-- Test creating a table (as member of analytics_group)
USE CATALOG your_dev_catalog;
USE SCHEMA analytics_team;

CREATE TABLE IF NOT EXISTS test_table (
  id INT,
  name STRING,
  created_at TIMESTAMP
);

-- Verify table was created
SHOW TABLES;

-- Insert test data
INSERT INTO test_table VALUES (1, 'test', current_timestamp());

-- Query test data
SELECT * FROM test_table;

-- Clean up test table
DROP TABLE IF EXISTS test_table;
```

---

## Step 13: View Terraform State

```bash
# List all managed resources
terraform state list

# View details of a specific schema
terraform state show 'module.databricks_schema["analytics-team-schema"].databricks_schema.this'

# View all outputs
terraform output

# View specific output
terraform output schemas
```

---

## Common Post-Deployment Tasks

### Add a New Schema

```bash
# 1. Create new JSON file
nano ../../schemas/dev/new-team-schema.json

# 2. Define the schema (see schemas/README.md for format)

# 3. Plan the change
terraform plan

# 4. Apply
terraform apply
```

### Modify Existing Schema

```bash
# 1. Edit the JSON file
nano ../../schemas/dev/analytics-team-schema.json

# 2. Change properties or privileges

# 3. Plan the change
terraform plan

# 4. Apply
terraform apply
```

### Remove a Schema

**⚠️ WARNING:** This deletes the schema and ALL its data!

```bash
# 1. Delete the JSON file
rm ../../schemas/dev/old-schema.json

# 2. Plan the destruction
terraform plan

# 3. Review carefully!
# 4. Apply (will destroy the schema)
terraform apply
```

---

## Troubleshooting

### Issue: `terraform init` fails with certificate error

**Solution:**
```bash
# Try with insecure flag (not recommended for production)
terraform init -upgrade

# Or check your network/VPN settings
```

### Issue: "Catalog not found"

**Solution:**
```sql
-- Create the catalog first
CREATE CATALOG IF NOT EXISTS your_dev_catalog;
```

### Issue: "Group not found: analytics_group"

**Solution:**
1. Go to Databricks Settings → Identity and access → Groups
2. Click "Create group"
3. Enter group name: `analytics_group`
4. Add members
5. Run `terraform apply` again

### Issue: "Permission denied"

**Solution:**
```sql
-- Grant yourself CREATE SCHEMA permission
GRANT CREATE SCHEMA ON CATALOG your_dev_catalog TO `your.email@company.com`;

-- Or ask your workspace admin to grant permissions
```

### Issue: "Schema already exists"

**Solution - Option 1: Import existing schema**
```bash
terraform import 'module.databricks_schema["analytics-team-schema"].databricks_schema.this' "your_dev_catalog.analytics_team"
```

**Solution - Option 2: Remove existing schema first**
```sql
-- In Databricks SQL Editor (WARNING: deletes data!)
DROP SCHEMA IF EXISTS your_dev_catalog.analytics_team CASCADE;
```

Then run `terraform apply` again.

### Issue: Authentication fails

**Solution:**
```bash
# Verify environment variables
env | grep DATABRICKS

# Test connection
curl -X GET \
  -H "Authorization: Bearer $DATABRICKS_TOKEN" \
  "$DATABRICKS_HOST/api/2.1/unity-catalog/catalogs"

# Re-export variables
export DATABRICKS_HOST="https://adb-xxx.azuredatabricks.net"
export DATABRICKS_TOKEN="dapi..."
```

### Issue: Plan shows unexpected changes

**Solution:**
```bash
# See what changed
terraform plan

# If confused, check current state
terraform state list
terraform state show 'resource.name'

# Refresh state from Databricks
terraform refresh
```

---

## Clean Up (For Testing Only)

If you want to remove everything:

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Type 'yes' when prompted
```

**⚠️ WARNING:** This deletes all schemas and their data!

---

## Next Steps

After successful deployment:

1. **Configure Remote Backend** (for team collaboration)
   - Copy `backend.tf.example` to `backend.tf`
   - Configure Azure Storage or S3
   - Run `terraform init -migrate-state`

2. **Set Up CI/CD** (optional)
   - Automate `terraform plan` on pull requests
   - Require approval before `terraform apply`

3. **Promote to Test**
   - Copy schemas to `schemas/test/`
   - Update environment property
   - Apply in `environments/test/`

4. **Document Your Process**
   - Create team runbook
   - Document approval process
   - Train team members

---

## Quick Reference

```bash
# Common commands (run from environments/dev/)

# Initialize
terraform init

# Validate syntax
terraform validate

# Preview changes
terraform plan

# Apply changes
terraform apply

# View state
terraform state list

# View outputs
terraform output

# Destroy all
terraform destroy

# Format code
terraform fmt -recursive

# Show specific resource
terraform state show 'module.databricks_schema["analytics-team-schema"].databricks_schema.this'
```

---

**Questions?** Check the [TESTING_GUIDE.md](TESTING_GUIDE.md) or [README.md](README.md)

**Last Updated:** November 7, 2025

