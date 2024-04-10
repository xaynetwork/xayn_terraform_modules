resource "opentelekomcloud_swr_organization_v2" "org" {
  name = var.name
}

resource "opentelekomcloud_swr_repository_v2" "repo_1" {
  count        = length(var.repository)
  organization = opentelekomcloud_swr_organization_v2.org.name
  name         = var.repository[count.index].repository_name
  description  = var.repository[count.index].repository_description
  category     = var.repository[count.index].repository_category
  is_public    = var.repository[count.index].repository_public
}
