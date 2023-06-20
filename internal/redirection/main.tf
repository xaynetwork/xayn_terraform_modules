locals {
  domain_name = var.apex_domain != "" ? var.apex_domain : var.domain_name
  origin_id   = var.apex_domain != "" ? "redirect-${var.apex_domain}" : "redirect-${var.domain_name}"
}

resource "aws_s3_bucket" "redirect" {
  bucket = local.domain_name

  tags = var.tags
}

resource "aws_s3_bucket_website_configuration" "redirect" {
  bucket = aws_s3_bucket.redirect.bucket

  redirect_all_requests_to {
    host_name = var.host_name
  }
}

module "acm" {
  providers = {
    aws = aws.us-east-1
  }
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.1"

  domain_name = local.domain_name
  zone_id     = var.hosted_zone_id

  subject_alternative_names = [
    "www.${local.domain_name}"
  ]

  wait_for_validation = true

  tags = var.tags
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.redirect.website_endpoint
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = false
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = [local.domain_name, "www.${local.domain_name}"]

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }

  tags = var.tags
}

resource "aws_route53_record" "redirect" {
  zone_id = var.hosted_zone_id
  name    = local.domain_name
  type    = "CNAME"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "redirect_www" {
  zone_id = var.hosted_zone_id
  name    = "www.${local.domain_name}"
  type    = "CNAME"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
