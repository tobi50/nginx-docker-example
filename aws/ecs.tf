resource "aws_ecs_cluster" "cluster" {
  name = local.role
}

resource "aws_ecs_service" "service" {
  name                               = local.role
  cluster                            = local.role
  launch_type                        = "FARGATE"
  task_definition                    = "${aws_ecs_task_definition.task_definition.family}:${max("${aws_ecs_task_definition.task_definition.revision}", "${aws_ecs_task_definition.task_definition.revision}")}"
  deployment_minimum_healthy_percent = 100
  desired_count                      = "1"
  scheduling_strategy                = "REPLICA"
  health_check_grace_period_seconds  = 120

  load_balancer {
    container_name   = local.role
    container_port   = "80"
    target_group_arn = aws_alb_target_group.target_group.arn
  }

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.internal.id]
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = local.role
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = jsonencode([{
    name  = local.role
    image = "nginx:latest"
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
  }])
}
