module "dynamodb_table" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table?ref=v3.1.2"

  name = "saas"

  ######
  # DataType # DataId
  # tenants  |  0001   | { auth-keys: [...],  name: "John Doe"}
  #          |  0002   | {...}
  # settings |  global | { max-signup-limit: 100 }    

  hash_key            = "dataType"
  range_key           = "dataId"
  billing_mode        = "PROVISIONED"

  attributes = [
    {
      name = "dataType"
      type = "S"
    },
    {
      name = "dataId"
      type = "S"
    }
  ]

  tags = var.tags
}
