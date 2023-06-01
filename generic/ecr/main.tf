################################################################################
# ECR Repository
# From https://github.com/terraform-aws-modules/terraform-aws-ecr/tree/master/examples/complete
################################################################################

module "ecr" {
  for_each = toset(var.repo_names)
  source   = "terraform-aws-modules/ecr/aws"
  version  = "1.5.1"

  repository_name = each.key
  repository_type = var.repository_type

  create_lifecycle_policy = true
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

  repository_read_access_arns = [for item in var.read_access_account_ids : "arn:aws:iam::${item}:root"]
  repository_force_delete     = true

  tags = var.tags
}
