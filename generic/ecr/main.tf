data "aws_region" "current" {}

################################################################################
# ECR Repository
# From https://github.com/terraform-aws-modules/terraform-aws-ecr/tree/master/examples/complete
################################################################################




module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.5.1"

  repository_name = var.name

  repository_read_write_access_arns = []
  create_lifecycle_policy           = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_force_delete = true

  tags = var.tags
}
