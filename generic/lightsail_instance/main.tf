locals {
  user_script          = file("${path.module}/scripts/user_data.sh")
  docker_instance_name = "web-demo"
}

data "aws_region" "current" {}

resource "aws_lightsail_instance" "this" {
  name              = var.service_name
  availability_zone = var.zone
  blueprint_id      = var.blueprint_id
  bundle_id         = var.bundle_id
  user_data         = var.user_data == null ? local.user_script : var.user_data
}

# Domain settings
data "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_route53_record" "custom_domain" {
  name    = var.subdomain_name
  type    = "A"
  records = [aws_lightsail_instance.this.public_ip_address]
  ttl     = 300
  zone_id = data.aws_route53_zone.this.id
}

locals {
  envs           = join(" ", formatlist("%s=%s", keys(var.docker_container_envs), values(var.docker_container_envs)))
  program_create = "${path.module}/scripts/update_docker.sh ${var.aws_profile} ${data.aws_region.current.name} ${var.service_name} ${local.docker_instance_name} ${var.docker_container} ${aws_lightsail_instance.this.public_ip_address} ${var.docker_container_port} ${local.envs} > docker_create.log && echo \"{\"result\": \"ok\"}\""
  program_delete = "${path.module}/scripts/delete_docker.sh  ${var.aws_profile} ${data.aws_region.current.name} ${var.service_name} ${local.docker_instance_name} ${aws_lightsail_instance.this.public_ip_address}"
  program_read   = "${path.module}/scripts/read_docker.sh  ${var.aws_profile} ${data.aws_region.current.name} ${var.service_name} ${local.docker_instance_name} ${aws_lightsail_instance.this.public_ip_address}"
}

resource "shell_script" "invoke_docker" {
  lifecycle_commands {
    create = local.program_create
    delete = local.program_delete
    update = local.program_create
    read   = local.program_read
  }

  triggers = {
    when_value_changed = "${var.docker_container} ${aws_lightsail_instance.this.public_ip_address} ${var.docker_container_port} ${local.envs}"
  }
}

