locals {
  bucket_name = replace(lower(var.bucket_name), "_", "-")
}

data "onepassword_item" "ak" {
  vault = var.vault_id
  uuid  = var.access_key_uid
}

data "onepassword_item" "sk" {
  vault = var.vault_id
  uuid  = var.secret_key_uid
}

resource "opentelekomcloud_obs_bucket" "tf_remote_state" {
  bucket     = local.bucket_name
  acl        = "private"
  versioning = true
  server_side_encryption {
    algorithm  = "kms"
    kms_key_id = opentelekomcloud_kms_key_v1.tf_remote_state_bucket_kms_key.id
  }
}

resource "opentelekomcloud_obs_bucket_policy" "policy" {
  bucket = opentelekomcloud_obs_bucket.tf_remote_state.id
  policy = <<POLICY
{
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "ID": ["*"]
    },
    "Action": [
      "GetObject",
      "PutObject"
    ],
    "Resource": [
      "${opentelekomcloud_obs_bucket.tf_remote_state.bucket}/*"
    ]
  }]
}
POLICY
}

resource "random_id" "id" {
  byte_length = 4
}

resource "opentelekomcloud_kms_key_v1" "tf_remote_state_bucket_kms_key" {
  key_alias       = "${local.bucket_name}-key-${random_id.id.hex}"
  key_description = "${local.bucket_name} encryption key"
  pending_days    = 7
  is_enabled      = "true"
}


