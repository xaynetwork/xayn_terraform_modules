output "s3_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_id" {
  description = "The name of bucket."
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_prefix" {
  description = "Report path prefix."
  value       = var.s3_prefix
}

output "report_name" {
  description = "Unique name for the report. Must start with a number/letter and is case sensitive. Limited to 256 characters."
  value       = var.report_name
}
