output "backend_config" {
  value = <<EOT
    backend "s3" {
      bucket = "${opentelekomcloud_obs_bucket.tf_remote_state.bucket}"
      kms_key_id = "arn:aws:kms:${var.region}:${opentelekomcloud_kms_key_v1.tf_remote_state_bucket_kms_key.domain_id}:key/${opentelekomcloud_kms_key_v1.tf_remote_state_bucket_kms_key.id}"
      key = "tfstate"
      region = "${opentelekomcloud_obs_bucket.tf_remote_state.region}"
      endpoint = "obs.${var.region}.otc.t-systems.com"
      encrypt = true
      skip_region_validation = true
      skip_credentials_validation = true
    }
  EOT
}
