##
# ACM certificates
##
resource "aws_acm_certificate" "cdn" {
  provider = aws.us_east_1 # Required for CloudFront

  # Using `aws_s3_bucket.cdn.id` here causes Terraform to not know what the
  # domain_name will be until after apply, I guess?
  domain_name       = local.cdn_domain
  validation_method = "DNS"
  key_algorithm     = "EC_prime256v1"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.tags, {
    PartOf = aws_s3_bucket.cdn.id
  })
}

##
# Certificate validation
##
resource "aws_acm_certificate_validation" "cdn" {
  provider = aws.us_east_1 # Required for CloudFront

  certificate_arn         = aws_acm_certificate.cdn.arn
  validation_record_fqdns = [for record in cloudflare_record.cdn_validation : record.hostname]
}
