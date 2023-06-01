locals {
  db_name = "saas_tenants"
}

module "dynamodb_table" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table?ref=v3.1.2"

  name = local.db_name

  ######
  # tenantId # email
  #   0001   | { auth-keys: [...],  name: "John Doe"}
  #   0002   | {...}    

  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"
  stream_enabled = true
  stream_view_type = "KEYS_ONLY"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  tags = var.tags
}
