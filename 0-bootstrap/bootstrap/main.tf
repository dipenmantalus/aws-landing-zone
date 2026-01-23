# Look up all OUs under the Root
data "aws_organizations_organizational_units" "root_children" {
  parent_id = data.aws_organizations_organization.org.roots.0.id
}

# Create the OU ONLY if it doesn't exist
resource "aws_organizations_organizational_unit" "bootstrap" {
  count     = local.ou_exists ? 0 : 1
  name      = local.lz_config.bootstrap.bootstrap_ou_name
  parent_id = data.aws_organizations_organization.org.roots.0.id
}

# Create the Account ONLY if it doesn't exist
resource "aws_organizations_account" "bootstrap" {
  count = local.account_exists ? 0 : 1

  name      = local.lz_config.bootstrap.bootstrap_account_name
  parent_id = local.final_ou_id # Uses the logic from locals
  email     = local.lz_config.bootstrap.bootstrap_account_email
  role_name = "OrganizationAccountAccessRole"

  lifecycle {
    ignore_changes = [role_name]
  }
}