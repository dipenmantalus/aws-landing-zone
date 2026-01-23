provider "aws" {
  alias  = "lzcicd"
  region = local.lz_config.global.home_region
  assume_role {
    # Dynamically targets the account ID fetched in bootstrap
    role_arn = "arn:aws:iam::${data.terraform_remote_state.remote.outputs.accounts_id_map.lz_ci_cd}:role/OrganizationAccountAccessRole"
  }
  default_tags {
    tags = merge(local.lz_config.default_tags.common, local.lz_config.default_tags.account.core)
  }
}

provider "awsutils" {
  region = local.lz_config.global.home_region
  assume_role {
    # Uses the global variable from lzconfig.yaml for the role name
    role_arn = "arn:aws:iam::${data.terraform_remote_state.remote.outputs.accounts_id_map.lz_ci_cd}:role/${local.lz_config.global.switch_role_to_assume}"
  }
}