output "accounts_id_map" {
  description = "Map of account names to IDs for the Landing Zone"
  value = {
    # UPDATED: Use the logic-safe final_account_id from locals.tf [cite: 4, 7]
    "lz_ci_cd" = local.final_account_id
  }
}

output "ci_cd_master_role_arn" {
  description = "The ARN of the CI/CD Master Role"
  # UPDATED: If the role exists, construct the ARN manually; otherwise, get it from the resource [cite: 1]
  # We use try() to handle the case where the resource count is 0
  value = local.role_exists ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ci-cd-master-Role" : try(aws_iam_role.ci-cd-master-role[0].arn, "")
}