module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  cluster_name                   = local.role
  cluster_version                = "1.25"
  cluster_endpoint_public_access = true

  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }
  }

  fargate_profiles = merge(
    {
      example = {
        name = local.role
        selectors = [
          {
            namespace = local.role
            labels = {
              Application = local.role
            }
          }
        ]

        # Using specific subnets instead of the subnets supplied for the cluster itself
        subnet_ids = [module.vpc.private_subnets[1]]

        tags = {
          Owner = "secondary"
        }

        timeouts = {
          create = "20m"
          delete = "20m"
        }
      }
    },
    { for i in range(2) :
      "kube-system-${element(split("-", local.azs[i]), 2)}" => {
        selectors = [
          { namespace = "kube-system" }
        ]
        # We want to create a profile per AZ for high availability
        subnet_ids = [element(module.vpc.private_subnets, i)]
      }
    }
  )

  tags = {
    Terraform = "true"
  }
}

resource "aws_iam_policy" "additional" {
  name        = "additional-policy"
  description = "Additional policy for EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "some-service:SomeAction",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
