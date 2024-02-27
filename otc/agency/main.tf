resource "opentelekomcloud_identity_agency_v3" "agency" {
  name                  = var.name
  description           = var.description
  delegated_domain_name = var.delegated_domain_name

  dynamic "project_role" {
    for_each = {
      for index, p in var.projects : index => p
    }
    content {
      project = project_role.value.project_name
      roles   = project_role.value.roles
    }
  }
}
