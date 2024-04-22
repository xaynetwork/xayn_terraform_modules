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

resource "opentelekomcloud_identity_user_v3" "ci_cd" {
  access_type = "programmatic"
  name        = "${var.name}-ci-cd"
}

resource "opentelekomcloud_swr_organization_permissions_v2" "ci_cd" {
  auth         = 3
  organization = opentelekomcloud_swr_organization_v2.org.name
  user_id      = opentelekomcloud_identity_user_v3.ci_cd.id
  username     = opentelekomcloud_identity_user_v3.ci_cd.name
}

resource "opentelekomcloud_identity_credential_v3" "ci_cd" {
  description = "Created by Terraform"
  user_id     = opentelekomcloud_identity_user_v3.ci_cd.id
}
