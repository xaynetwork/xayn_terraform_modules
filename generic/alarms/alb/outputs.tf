output "repository_arns" {
  description = "Full ARN of the repository"
  value = toset([
    for i in module.ecr : i.repository_arn
  ])
}

output "repository_registry_ids" {
  description = "The registry IDs where the repository was created"
  value = toset([
    for i in module.ecr : i.repository_registry_id
  ])
}

output "repository_urls" {
  description = "The URLs of the repository (in the form `aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName`)"
  value = toset([
    for i in module.ecr : i.repository_url
  ])
}
