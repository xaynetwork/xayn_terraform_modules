resource "aws_s3_bucket" "static_website" {
  bucket = var.url_name

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# resource "aws_s3_bucket_website_configuration" "bucket_website" {
#   bucket = aws_s3_bucket.static_website.bucket

#   redirect_all_requests_to {
#     host_name = var.host_name
#     protocol  = "https"
#   }
# }

# locals {
#   s3_origin_id = "S3Origin"
# }

# module "acm" {
#   source = "terraform-aws-modules/acm/aws"

#   providers = {
#     aws = aws.us-east-1
#   }

#   domain_name = "support.xayn.com"
#   zone_id     = var.hosted_zone_id

#   subject_alternative_names = [
#     "*.support.xayn.com",
#   ]

#   wait_for_validation = true

#   tags = var.tags
# }

# module "cdn" {
#   source = "terraform-aws-modules/cloudfront/aws"

#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"
#   retain_on_delete    = false
#   wait_for_deployment = false

#   create_origin_access_identity = true
#   origin_access_identities = {
#     s3_bucket_one = "My awesome CloudFront can access"
#   }

#   origin = {
#     s3_one = {
#       domain_name = aws_s3_bucket.static_website.bucket_domain_name
#       s3_origin_config = {
#         origin_access_identity = "s3_bucket_one"
#       }
#     }
#   }

#   default_cache_behavior = {
#     target_origin_id       = "s3_one"
#     viewer_protocol_policy = "redirect-to-https"

#     allowed_methods = ["GET", "HEAD", "OPTIONS"]
#     cached_methods  = ["GET", "HEAD"]
#     compress        = true
#     query_string    = true
#   }

#   viewer_certificate = {
#     acm_certificate_arn = module.acm.acm_certificate_arn
#     ssl_support_method  = "sni-only"
#   }
# }

# resource "aws_cloudfront_distribution" "s3_distribution" {
#   origin {
#     domain_name              = aws_s3_bucket.static_website.bucket_domain_name
#     origin_id                = local.s3_origin_id
#   }

#   enabled             = true
#   is_ipv6_enabled     = true

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "whitelist"
#       locations        = ["US", "CA", "GB", "DE"]
#     }
#   }

#   tags = var.tags

#   viewer_certificate {
#     acm_certificate_arn = module.acm.acm_certificate_arn
#     ssl_support_method = "sni-only"
#   }
# }

resource "aws_route53_record" "this" {
  zone_id = var.hosted_zone_id
  name    = var.url_name
  type    = "A"
  alias {
    name                   = aws_s3_bucket.static_website.bucket_domain_name
    zone_id                = aws_s3_bucket.static_website.hosted_zone_id
    evaluate_target_health = false
  }
}
