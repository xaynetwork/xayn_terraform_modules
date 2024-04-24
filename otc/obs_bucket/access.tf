data "opentelekomcloud_identity_project_v3" "obs_project" {
  name = "MOS"
}

resource "opentelekomcloud_identity_role_v3" "models" {
  display_name  = "${var.bucket_name}-obs-role"
  description   = "OBS bucket access role for ${var.bucket_name}."
  display_layer = "domain"
  statement {
    effect = "Allow"
    resource = [
      "obs:*:*:bucket:${opentelekomcloud_obs_bucket.models.id}"
    ]
    action = [
      "obs:bucket:ListAllMybuckets",
      "obs:bucket:HeadBucket",
      "obs:bucket:ListBucket",
      "obs:bucket:GetBucketLocation",
      "obs:bucket:ListBucketMultipartUploads",
    ]
  }
  statement {
    effect = "Allow"
    resource = [
      "obs:*:*:object:${opentelekomcloud_obs_bucket.models.id}/*",
    ]
    action = [
      "obs:object:GetObject",
      "obs:object:GetObjectVersion",
      "obs:object:PutObject",
      "obs:object:DeleteObject",
      "obs:object:DeleteObjectVersion",
      "obs:object:ListMultipartUploadParts",
      "obs:object:AbortMultipartUpload",
      "obs:object:GetObjectAcl",
      "obs:object:GetObjectVersionAcl",
      "obs:object:ModifyObjectMetaData",
    ]
  }
}

resource "opentelekomcloud_identity_role_assignment_v3" "obs_project" {
  group_id   = opentelekomcloud_identity_group_v3.models.id
  project_id = data.opentelekomcloud_identity_project_v3.obs_project.id
  role_id    = opentelekomcloud_identity_role_v3.models.id
}
