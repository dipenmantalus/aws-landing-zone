resource "aws_iam_role" "codepipeline_role" {
  count = local.cp_role_exists ? 0 : 1
  name  = "codepipeline-${var.git_repository_name}-Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "codepipeline.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline-${var.git_repository_name}-policy"
  role = local.cp_role_name

  policy = templatefile("${path.module}/templates/codepipeline-role-policy.json.tpl", {
    codepipeline_bucket_arn = aws_s3_bucket.codepipeline_bucket.arn
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_codecommit" {
  role       = local.cp_role_name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
}