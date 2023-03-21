resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  vpc_id      = module.vpc.vpc_id
  description = local.description
  tags = {
    Name      = "allow_all"
    Terraform = "true"
  }
}

resource "aws_security_group_rule" "allow_all_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_all.id
}

resource "aws_security_group" "internal" {
  name        = "internal"
  vpc_id      = module.vpc.vpc_id
  description = local.description
  tags = {
    Name      = "internal"
    Terraform = "true"
  }
}

resource "aws_security_group_rule" "internal_eegress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.internal.id
}

resource "aws_security_group_rule" "internal_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  self              = true
  security_group_id = aws_security_group.internal.id
}
