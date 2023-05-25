resource "aws_s3_bucket" "redirect" {
  bucket = var.domain_name

  tags = var.tags
}

resource "aws_s3_bucket_website_configuration" "redirect" {
  bucket = aws_s3_bucket.redirect.bucket

  redirect_all_requests_to {
    host_name = var.host_name
  }
}
