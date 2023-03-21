locals {
  region      = "ap-northeast-1"
  description = "This is a terraform example for nginx-docker-example."
  role        = "nginx"
  env         = "example"
}

data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
