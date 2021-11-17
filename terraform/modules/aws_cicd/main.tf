provider "github" {
  token = var.webhook_secret
  owner = var.github_username
}
data "local_file" "buildspec" {
    filename = "${path.module}/templates/buildspec.yml"
}

# A shared secret between GitHub and AWS that allows AWS
# CodePipeline to authenticate the request came from GitHub.
# Would probably be better to pull this from the environment
# or something like SSM Parameter Store.
locals {
  webhook_secret = var.webhook_secret 
}

# resource "aws_codestarconnections_connection" "githubV2_connection" {
#   name          = "github_codestar_connection"
#   provider_type = "GitHub"
# }

resource "aws_cloudwatch_log_group" "codebuild-log-group" {
  name = "${var.codebuild_project_name}-cw-LogGroup"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.codebuild_project_name}-cw-LogGroup"
    },
  )
}

resource "aws_codebuild_project" "docker_image_codebuild" {
  name           = var.codebuild_project_name
  badge_enabled  = false
  build_timeout  = 300
  queued_timeout = 300
  service_role   = aws_iam_role.codebuild_Service_role.arn
  tags = merge(
    var.tags,
    {
      "Name" = "${var.codebuild_project_name}-project"
    },
  )
  source {
    buildspec           = data.local_file.buildspec.content
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
  artifacts {
    encryption_disabled    = true
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
    environment_variable {
      name  = "ECR_REPOSITORY_URL"
      value = var.ecr_repo_url
    }
    environment_variable {
      name  = "AWS_ACCOUNT_NO"
      value = var.aws_account_no
    }
    environment_variable{
      name  = "AWS_DEFAULT_REGION"
      value = var.region
      }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name  = aws_cloudwatch_log_group.codebuild-log-group.name
    }
  }

#   vpc_config {
#     vpc_id = var.vpc_id
#     subnets = var.private_subnets
#     security_group_ids = [var.default_sg_id]
#   }
}


resource "aws_codepipeline" "ecs-codepipeline" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.codepipeline_Service_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Github_Source_Stage"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      # provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      # configuration = {
      #   ConnectionArn    = aws_codestarconnections_connection.githubV2_connection.arn
      #   FullRepositoryId = "${var.github_username}/${var.github_repo_name}"
      #   BranchName       = var.github_branch_name
      # }

      configuration = {
        Owner  = var.github_username
        Repo   = var.github_repo_name
        Branch = var.github_branch_name
        OAuthToken = var.github_token
      }      
    }
  }

  stage {
    name = "Build"
    action {
      name             = "CodeBuild_Stage"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.docker_image_codebuild.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name = "ECS_Deploy_Stage"
      category = "Deploy"
      configuration = {
        ClusterName = var.ecs_cluster_name 
        ServiceName = var.ecs_service_name 
      }
      input_artifacts = ["BuildArtifact"]
      owner            = "AWS"
      provider         = "ECS"
      run_order        = 1
      version          = "1"
    }
  }

  // ignore GitHub's OAuthToken
  lifecycle {
    ignore_changes = [
      stage[0].action[0].configuration 
    ]
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.codepipeline_name}"
    },
  )
}

resource "aws_codepipeline_webhook" "codepipeline_webhook" {
  name            = "codepipeline-github-webhook-ecs-go-app"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.ecs-codepipeline.name

  authentication_configuration {
    secret_token = local.webhook_secret
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

# Wire the CodePipeline webhook into a GitHub repository.
resource "github_repository_webhook" "github_webhook" {
  events = ["push"]
  active     = true
  repository = var.github_repo_name
  configuration {
    url          = aws_codepipeline_webhook.codepipeline_webhook.url
    content_type = "json"
    insecure_ssl = false
    secret       = local.webhook_secret
  }
}
