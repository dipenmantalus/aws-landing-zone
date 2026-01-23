resource "aws_iam_role" "ci-cd-master-role" {
  # NEW: Count logic to skip if exists
  count = local.role_exists ? 0 : 1
  name  = "ci-cd-master-Role"

  depends_on = [
    aws_organizations_account.bootstrap
  ]

  assume_role_policy = <<-EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::${local.final_account_id}:root"
			},
			"Action": "sts:AssumeRole"
		}
	]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ci-cd-master-role-policy" {
  # Only manage attachment if we are managing the role
  count      = local.role_exists ? 0 : 1
  role       = aws_iam_role.ci-cd-master-role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}