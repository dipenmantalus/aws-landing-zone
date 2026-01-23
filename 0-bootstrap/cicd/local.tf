locals {
  lz_config = yamldecode(file("../../lzconfig.yaml"))

  # This fetches the account ID from the bootstrap state file 
  # so it can be used in your providers and outputs.
  cicd_account_id = data.terraform_remote_state.remote.outputs.accounts_id_map.lz_ci_cd

  # Role used by CodeBuild for master account operations
  master_role_to_assume = ["arn:aws:iam::${data.aws_organizations_organization.org.master_account_id}:role/ci-cd-master-Role"]
}