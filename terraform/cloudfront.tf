##
# CloudFront Distributions
##
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name              = aws_s3_bucket.cdn.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cdn.id
    origin_id                = local.s3_origin_id
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "CloudFront for ${local.cdn_domain}"

  aliases = [local.cdn_domain]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cdn.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  tags = merge(local.tags, {
    PartOf = aws_s3_bucket.cdn.id
  })

  depends_on = [
    aws_acm_certificate.cdn,
    aws_acm_certificate_validation.cdn
  ]
}

##
# Origin Access Identities
##
resource "aws_cloudfront_origin_access_control" "cdn" {
  name                              = aws_s3_bucket.cdn.bucket_domain_name
  description                       = "Origin access identity for ${local.cdn_domain}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
