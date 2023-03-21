locals {
  region      = "ap-northeast-1"
  azs         = ["${local.region}a", "${local.region}c"]
  description = "This is a terraform example for nginx-docker-example."
  role        = "nginx"
  env         = "example"
}
