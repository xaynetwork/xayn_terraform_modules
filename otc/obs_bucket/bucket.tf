resource "opentelekomcloud_obs_bucket" "models" {
  bucket     = local.bucket_name
  acl        = "private"
  versioning = false
}
