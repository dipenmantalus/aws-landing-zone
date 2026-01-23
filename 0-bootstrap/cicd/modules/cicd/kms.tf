resource "aws_kms_key" "codebuild-key" {
  count                   = local.kms_alias_exists ? 0 : 1
  description             = "Key to be used by CodeBuild to encrypt data"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_kms_alias" "codebuild-key" {
  count         = local.kms_alias_exists ? 0 : 1
  name          = "alias/codebuild-${var.git_repository_name}-key"
  target_key_id = aws_kms_key.codebuild-key[0].key_id
}