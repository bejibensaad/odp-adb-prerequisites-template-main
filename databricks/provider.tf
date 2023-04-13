# Initialize the Databricks Terraform provider.
terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

# Use environment variables for authentication.
provider "databricks" {}

# Retrieve information about the current user.
data "databricks_current_user" "me" {}