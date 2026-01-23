resource "aws_codebuild_project" "codebuild_deployment" {
  for_each      = local.filtered_build_stages
  name          = "${var.git_repository_name}-${each.key}"
  description   = "Code build project for ${var.git_repository_name} ${each.key} stage"
  build_timeout = "120"

  service_role   = "arn:aws:iam::${local.account_id}:role/${local.cb_role_name}"
  encryption_key = local.codebuild_kms_key_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  environment {
    image                       = var.codebuild_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = var.cb_priviledged_mode
    compute_type                = var.codebuild_node_size

    dynamic "environment_variable" {
      for_each = var.proxy_config["HTTP_PROXY"] != "" ? var.proxy_config : {}
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  dynamic "vpc_config" {
    for_each = var.priv_vpc_config["vpc_id"] != "" ? [var.priv_vpc_config["vpc_id"]] : []
    content {
      vpc_id             = var.priv_vpc_config["vpc_id"]
      subnets            = split(",", var.priv_vpc_config["subnet_ids"])
      security_group_ids = split(",", var.priv_vpc_config["security_group_ids"])
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.codebuild_bucket.id}/${each.key}/build_logs"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = each.value
  }

  tags = var.custom_tags
}