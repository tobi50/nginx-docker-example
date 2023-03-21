# VPC モジュールの定義
module "vpc" {
  # モジュールのソースとして、terraform-aws-modules/vpc/aws を使用
  source = "terraform-aws-modules/vpc/aws"

  # VPC の名前をローカル変数 "env" から設定
  name = local.env

  # VPC の CIDR ブロックを指定
  cidr = "10.0.0.0/16"

  # 可用性ゾーン (AZ) を指定
  azs = ["${local.region}a", "${local.region}c"]

  # プライベートサブネットの CIDR ブロックを指定
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  # パブリックサブネットの CIDR ブロックを指定
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  # NAT ゲートウェイを有効にする
  enable_nat_gateway = true

  # タグを設定
  tags = {
    Terraform = "true"
  }
}

# プライベートサブネットの ID のリストを出力
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

# パブリックサブネットの ID のリストを出力
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# 全てを許可するセキュリティグループの定義
resource "aws_security_group" "allow_all" {
  # セキュリティグループの名前
  name = "allow_all"

  # VPC ID を設定 (module.vpc.vpc_id で取得)
  vpc_id = module.vpc.vpc_id

  # セキュリティグループの説明
  description = local.description

  # タグを設定
  tags = {
    Name      = "allow_all"
    Terraform = "true"
  }
}

# HTTP 通信を許可するセキュリティグループルールの定義
resource "aws_security_group_rule" "allow_all_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_all.id
}

# 内部通信のみを許可するセキュリティグループの定義
resource "aws_security_group" "internal" {
  # セキュリティグループの名前
  name = "internal"

  # VPC ID を設定 (module.vpc.vpc_id で取得)
  vpc_id = module.vpc.vpc_id

  # セキュリティグループの説明
  description = local.description

  # タグを設定
  tags = {
    Name      = "internal"
    Terraform = "true"
  }
}

# すべての外部への通信を許可するセキュリティグループルールの定義
resource "aws_security_group_rule" "internal_eegress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.internal.id
}

# セキュリティグループ内のすべての通信を許可するセキュリティグループルールの定義
resource "aws_security_group_rule" "internal_ingress" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "all"

  # 自分自身のセキュリティグループに対して許可
  self = true

  security_group_id = aws_security_group.internal.id
}

# Amazon ECS タスク実行ロールの IAM ロールリソースを定義
# 注：今回は "Welcome to nginx" を表示するだけのコンテナを起動するため、タスク（コンテナ）から他の AWS リソースへアクセスする必要がないため、タスク（コンテナ）に IAM ロールをアタッチしません
resource "aws_iam_role" "ecsTaskExecutionRole" {
  # ロール名を設定)
  name = "ecs_${local.role}_task_execution_role"

  # ロールの説明をローカル変数 "description" から設定
  description = local.description

  # ロールの信頼ポリシーを設定
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# アプリケーションロードバランサ (ALB) のリソース定義
resource "aws_alb" "lb" {
  # ALB の名前
  name = local.role

  # ロードバランサのタイプ (アプリケーション)
  load_balancer_type = "application"

  # ALB に関連付けるセキュリティグループ
  security_groups = [aws_security_group.internal.id, aws_security_group.allow_all.id]

  # ALB に関連付けるサブネット (パブリックサブネット)
  subnets = module.vpc.public_subnets

  # ALB をインターネット向けに設定
  internal = false

  # ALB の削除保護を無効化
  enable_deletion_protection = false

  # タグを設定
  tags = {
    Terraform = "true"
  }
}

# ALB ターゲットグループのリソース定義
resource "aws_alb_target_group" "target_group" {
  name                 = local.role
  port                 = "80"
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = "300"

  # ヘルスチェック設定
  health_check {
    interval            = "120"
    path                = "/"
    protocol            = "HTTP"
    timeout             = "5"
    healthy_threshold   = "5"
    unhealthy_threshold = "3"
    matcher             = "200"
  }

  # タグを設定
  tags = {
    Managed = "Terraform"
  }
}

# ALB リスナーのリソース定義 (HTTP プロトコル)
resource "aws_alb_listener" "lb_listener_http" {
  load_balancer_arn = aws_alb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  # デフォルトアクション設定 (フォワード)
  default_action {
    target_group_arn = aws_alb_target_group.target_group.arn
    type             = "forward"
  }
}

# ALB の DNS 名をアウトプット
output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_alb.lb.dns_name
}

# ECS クラスタのリソース定義
resource "aws_ecs_cluster" "cluster" {
  name = local.role
}

# ECS サービスのリソース定義
resource "aws_ecs_service" "service" {
  name                               = local.role
  cluster                            = local.role
  launch_type                        = "FARGATE"
  task_definition                    = "${aws_ecs_task_definition.task_definition.family}:${max("${aws_ecs_task_definition.task_definition.revision}", "${aws_ecs_task_definition.task_definition.revision}")}"
  deployment_minimum_healthy_percent = 100
  desired_count                      = "1"
  scheduling_strategy                = "REPLICA"
  health_check_grace_period_seconds  = 120

  # ALB ターゲットグループとの紐付け
  load_balancer {
    container_name   = local.role
    container_port   = "80"
    target_group_arn = aws_alb_target_group.target_group.arn
  }

  # ネットワーク設定
  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.internal.id]
  }
}

# ECS タスク定義のリソース定義
resource "aws_ecs_task_definition" "task_definition" {
  family                   = local.role
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  # コンテナ定義
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
