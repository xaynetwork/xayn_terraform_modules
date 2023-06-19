module "ssm" {
  source = "github.com/xaynetwork/terraform-aws-session-manager?ref=019acc85810cc7f152632c3c14018848e02cf796"

  kms_key_alias            = "alias/session-logs-key"
  enable_log_to_cloudwatch = true
  enable_log_to_s3         = false
  tags                     = var.tags
}

module "ssm_user_policy" {
  source = "../ssm_user_policy"

  prefix      = var.prefix
  kms_key_arn = module.ssm.kms_key_arn
  tags        = var.tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.0"

  name        = "${var.name}-sg"
  description = "Security group of the bastion host"
  vpc_id      = var.vpc_id

  egress_cidr_blocks = var.egress_cidr_blocks
  egress_with_cidr_blocks = [
    {
      description = "HTTPS for Session Manger and Elasticsearch"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "For communicating with Elasticsearch"
      from_port   = 9243
      to_port     = 9243
      protocol    = "tcp"
    },
    {
      description = "For communicating with Postgres"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
    }
  ]

  tags = var.tags
}

module "ec2" {
  source = "../ec2"

  name                   = var.name
  quantity               = var.quantity
  iam_profile_name       = module.ssm.iam_profile_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [module.security_group.security_group_id]
  tags                   = var.tags
}
