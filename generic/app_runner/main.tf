################################################################################
# APP Runner Repository
# From https://github.com/terraform-aws-modules/terraform-aws-app-runner
################################################################################

module "app_runner" {
  source  = "terraform-aws-modules/app-runner/aws"
  version = "1.2.0"

  service_name                     = var.service_name
  create_custom_domain_association = var.create_domain_association
  domain_name                      = var.subdomain_name

  source_configuration = {
    auto_deployments_enabled = var.configure_deployment
    image_repository = {
      image_configuration = {
        port = var.container_port
      }
      image_identifier      = var.container_image
      image_repository_type = "ECR"
    }
    authentication_configuration = {
      access_role_arn = var.access_role
    }
  }

  tags = var.tags
}

data "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_route53_record" "validation_records_linglinger_1" {
  name    = tolist(module.app_runner.output.custom_domain_association_certificate_validation_records)[0].name
  type    = tolist(module.app_runner.output.custom_domain_association_certificate_validation_records)[0].type
  records = [tolist(module.app_runner.output.custom_domain_association_certificate_validation_records)[0].value]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id

  depends_on = [
    module.app_runner
  ]
}

resource "aws_route53_record" "validation_records_linglinger_2" {
  name    = tolist(module.app_runner.output.custom_domain_association_certificate_validation_records)[1].name
  type    = tolist(module.app_runner.output.custom_domain_association_certificate_validation_records)[1].type
  records = [tolist(module.app_runner.output.custom_domain_association_certificate_validation_records)[1].value]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id

  depends_on = [
    module.app_runner
  ]
}

resource "aws_route53_record" "validation_records_linglinger_3" {
  name    = tolist(module.app_runner.output.custom_domain_association_certificate_validation_records)[2].name
  type    = tolist(module.app_runner.output.custom_domain_association_certificate_validation_records)[2].type
  records = [tolist(module.app_runner.output.custom_domain_association_certificate_validation_records)[2].value]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id

  depends_on = [
    module.app_runner
  ]
}

resource "aws_route53_record" "custom_domain" {
  name    = var.subdomain_name
  type    = "CNAME"
  records = [module.app_runner.output.service_url]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id

  depends_on = [
    module.app_runner
  ]
}
