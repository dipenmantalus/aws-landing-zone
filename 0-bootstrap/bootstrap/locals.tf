locals {
  lz_config = yamldecode(file("../../lzconfig.yaml"))

  # --- OU Logic ---
  existing_ou = [
    for ou in data.aws_organizations_organizational_units.root_children.children :
    ou.id if ou.name == local.lz_config.bootstrap.bootstrap_ou_name
  ]
  ou_exists   = length(local.existing_ou) > 0
  final_ou_id = local.ou_exists ? local.existing_ou[0] : try(aws_organizations_organizational_unit.bootstrap[0].id, null)

  # --- Account Logic ---
  existing_account = [
    for acc in data.aws_organizations_organization.org.accounts :
    acc.id if acc.name == local.lz_config.bootstrap.bootstrap_account_name
  ]
  account_exists   = length(local.existing_account) > 0
  final_account_id = local.account_exists ? local.existing_account[0] : try(aws_organizations_account.bootstrap[0].id, null)

  # --- IAM Role Logic ---
  role_exists = contains(data.aws_iam_roles.all.names, "ci-cd-master-Role")
}

# Data sources required for the logic above
data "aws_iam_roles" "all" {}
data "aws_caller_identity" "current" {}