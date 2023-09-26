data "aws_region" "current" {}

resource "ec_deployment_traffic_filter" "aws_vpce" {
  name   = "aws-${var.name}-traffic-filter"
  region = "aws-${data.aws_region.current.name}"
  type   = "vpce"

  rule {
    source = var.vpce_id
  }
}

resource "ec_deployment" "es_cluster" {
  name                   = var.name
  alias                  = var.alias != null ? var.alias : var.name
  region                 = "aws-${data.aws_region.current.name}"
  version                = var.es_version
  deployment_template_id = var.deployment_template

  traffic_filter = [
    ec_deployment_traffic_filter.aws_vpce.id
  ]

  elasticsearch {
    autoscale = "true"

    topology {
      id = "cold"
    }

    topology {
      id = "frozen"
    }

    topology {
      id   = "hot_content"
      size = "${var.hot_tier_memory}g"

      autoscaling {
        max_size = "${var.hot_tier_memory_max}g"
      }

      zone_count = var.hot_tier_zone_count
    }

    topology {
      id   = "ml"
      size = "${var.ml_tier_memory}g"

      autoscaling {
        max_size = "${var.ml_tier_memory_max}g"
      }

      zone_count = var.ml_tier_zone_count
    }

    topology {
      id = "warm"
    }
  }

  lifecycle {
    ignore_changes = [
      elasticsearch[0].topology[2].size,
      elasticsearch[0].topology[3].size
    ]
  }

  kibana {}
}

resource "aws_ssm_parameter" "elasticsearch_username" {
  description = "The name of the auto-generated Elasticsearch user"
  name        = "/elasticsearch/${var.name}/user"
  type        = "String"
  value       = ec_deployment.es_cluster.elasticsearch_username
  tags        = var.tags
}

resource "aws_ssm_parameter" "elasticsearch_password" {
  description = "The auto-generated Elasticsearch password"
  name        = "/elasticsearch/${var.name}/password"
  type        = "SecureString"
  value       = ec_deployment.es_cluster.elasticsearch_password
  tags        = var.tags
}

data "ec_aws_privatelink_endpoint" "this" {
  region = data.aws_region.current.name
}

resource "aws_ssm_parameter" "elasticsearch_url" {
  description = "URL of the Elasticsearch deployment"
  name        = "/elasticsearch/${var.name}/url"
  type        = "String"
  value       = "https://${ec_deployment.es_cluster.alias}.es.${data.ec_aws_privatelink_endpoint.this.domain_name}"
  tags        = var.tags
}
