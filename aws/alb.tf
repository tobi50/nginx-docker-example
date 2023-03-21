resource "aws_alb" "lb" {
  name               = local.role
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal.id, aws_security_group.allow_all.id]
  subnets            = module.vpc.public_subnets

  internal                   = false
  enable_deletion_protection = false

  tags = {
    Terraform = "true"
  }
}

resource "aws_alb_target_group" "target_group" {
  name                 = local.role
  port                 = "80"
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = "300"

  health_check {
    interval            = "120"
    path                = "/"
    protocol            = "HTTP"
    timeout             = "5"
    healthy_threshold   = "5"
    unhealthy_threshold = "3"
    matcher             = "200"
  }

  tags = {
    Managed = "Terraform"
  }
}

resource "aws_alb_listener" "lb_listener_http" {
  load_balancer_arn = aws_alb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.target_group.arn
    type             = "forward"

  }
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_alb.lb.dns_name
}
