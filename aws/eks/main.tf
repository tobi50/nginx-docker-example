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

