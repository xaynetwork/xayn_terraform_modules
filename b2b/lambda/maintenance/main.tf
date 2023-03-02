locals {
  function_name = "maintenance"
  script_path   = "${path.module}/function"
  output_path   = "${path.module}/function.zip"
}

data "external" "build" {
  program     = ["bash", "-c", "npm install > /dev/null && echo {}"]
  working_dir = local.script_path
}

#Cloudwatch Role
module "role" {
  source = "../../../generic/lambda/role"
  path   = "/${local.function_name}/"
  prefix = title(local.function_name)
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = module.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = module.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

module "security_group" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=v4.16.0"

  name        = "${local.function_name}-sg"
  description = "Security group for Elasticsearch, Postgres and SSM Parameter store access"
  vpc_id      = var.vpc_id

  egress_cidr_blocks = var.subnets_cidr_blocks
  egress_with_cidr_blocks = [
    {
      from_port   = 9243
      to_port     = 9243
      protocol    = "tcp"
      description = "Allow outbound traffic on Elasticsearch port"
    },
    {
      rule        = "https-443-tcp"
      description = "Allow outbound traffic on HTTPS (Elasticsearch and SSM Parameter store)"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "postgresql-tcp"
      description = "Allow outbound traffic on Postgres port"
    }
  ]

  tags = var.tags
}

### needs to have installed
### https://github.com/timo-reymann/deterministic-zip
### https://www.reddit.com/r/Terraform/comments/aupudn/building_deterministic_zips_to_minimize_lambda/
data "external" "source_code" {
  program     = ["bash", "-c", "deterministic-zip -r tmp.zip . && mv tmp.zip ../${local.output_path} && echo '{ \"output\": \"${local.output_path}\" }'"]
  working_dir = local.script_path

  depends_on = [
    data.external.build
  ]
}

module "function" {
  source                 = "../../../generic/lambda/function"
  function_name          = local.function_name
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  source_code_hash       = filebase64sha256(data.external.source_code.result.output)
  lambda_role_arn        = module.role.arn
  output_path            = local.output_path
  log_retention_in_days  = var.log_retention_in_days
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = [module.security_group.security_group_id]
  timeout                = 15

  tags = var.tags
}
