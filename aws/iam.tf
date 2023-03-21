resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecs_${local.role}_task_execution_role"
  description        = local.description
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}
