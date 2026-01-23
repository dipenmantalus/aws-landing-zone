locals {
  timestamp = "aws-lz-${replace("${timestamp()}", "/[-| |T|Z|:]/", "")}"
  buckets_to_lock = {
    codepipeline = aws_s3_bucket.codepipeline_bucket.id
    codebuild    = aws_s3_bucket.codebuild_bucket.id
  }

  region     = var.region != "" ? var.region : data.aws_region.current.name
  account_id = var.account_id != "" ? var.account_id : data.aws_caller_identity.current.account_id

  # --- Role Existence Logic ---
  cb_role_name_check = "${var.git_repository_name}_codebuild_deploy_Role"
  cb_role_exists     = contains(data.aws_iam_roles.all.names, local.cb_role_name_check)
  cb_role_name       = local.cb_role_exists ? local.cb_role_name_check : try(aws_iam_role.codebuild_role[0].name, "")

  cp_role_name_check = "codepipeline-${var.git_repository_name}-Role"
  cp_role_exists     = contains(data.aws_iam_roles.all.names, local.cp_role_name_check)
  cp_role_name       = local.cp_role_exists ? local.cp_role_name_check : try(aws_iam_role.codepipeline_role[0].name, "")

  # --- KMS Existence Logic ---
  kms_alias_exists      = can(data.aws_kms_alias.existing_codebuild_alias.target_key_id)
  codebuild_kms_key_arn = local.kms_alias_exists ? data.aws_kms_alias.existing_codebuild_alias.target_key_arn : try(aws_kms_key.codebuild-key[0].arn, "")

  # --- CodeBuild & CodePipeline Existence Logic ---
  # These are now DISABLED to allow Terraform to manage/replace the resources
  existing_cb_names = [] 
  existing_cp_names = []

  # Filters: No longer filtering so that Terraform attempts to manage these resources
  filtered_build_stages = var.code_pipeline_build_stages
  filtered_branches     = var.branches
}

# --- Data Sources ---
data "aws_iam_roles" "all" {}

data "aws_kms_alias" "existing_codebuild_alias" {
  name = "alias/codebuild-${var.git_repository_name}-key"
}