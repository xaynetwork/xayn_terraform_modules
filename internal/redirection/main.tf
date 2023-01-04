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

resource "aws_s3_bucket_website_configuration" "bucket_website" {
  bucket = aws_s3_bucket.static_website.bucket

  redirect_all_requests_to {
    host_name = var.host_name
    protocol  = "https"
  }
}

resource "aws_route53_record" "this" {
  zone_id = var.hosted_zone_id
  name    = var.url_name
  type    = "A"
  alias {
    name                   = aws_s3_bucket_website_configuration.bucket_website.website_domain
    zone_id                = aws_s3_bucket.static_website.hosted_zone_id
    evaluate_target_health = true
  }
}
