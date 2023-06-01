data "aws_region" "current" {}

data "ec_aws_privatelink_endpoint" "this" {
  region = data.aws_region.current.name
}

locals {
  name = "${var.name}-elastic-cloud"
}

module "security-group" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group?ref=v4.16.0"

  name        = "${local.name}-vpce-sg"
  description = "Security group for Elastic Cloud access"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.subnets_cidr_blocks

  ingress_with_cidr_blocks = [
    {
      from_port   = 9243
      to_port     = 9243
      protocol    = "tcp"
      description = "Elasticsearch port"
    },
    {
      rule        = "https-443-tcp"
      description = "Kibana port"
    }
  ]

  tags = var.tags
}

resource "aws_vpc_endpoint" "elastic_cloud" {
  vpc_id              = var.vpc_id
  service_name        = data.ec_aws_privatelink_endpoint.this.vpc_service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.security-group.security_group_id]
  subnet_ids          = var.subnets_ids
  private_dns_enabled = false

  tags = merge(
    var.tags,
    {
      Name = local.name
    }
  )
}

resource "aws_route53_zone" "elastic_cloud_private_link" {
  name = data.ec_aws_privatelink_endpoint.this.domain_name

  vpc {
    vpc_id = var.vpc_id
  }

  tags = var.tags
}

resource "aws_route53_record" "elastic_cloud_private_link_url" {
  zone_id = aws_route53_zone.elastic_cloud_private_link.zone_id
  name    = "*"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_vpc_endpoint.elastic_cloud.dns_entry[0]["dns_name"]]
}
