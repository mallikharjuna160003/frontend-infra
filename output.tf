output "s3_bucket_name" {
  value = aws_s3_bucket.frontend.id
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.frontend.id
}
output "website_endpoint" {
  value = aws_s3_bucket.frontend.bucket_regional_domain_name
}
/*
output "backend_cloudfront_domain" {
  value = aws_cloudfront_distribution.backend.domain_name
}
*/
