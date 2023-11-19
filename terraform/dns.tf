##
# Cloudflare DNS Records
##
resource "cloudflare_record" "domains" {
  for_each = {
    for index, domain in var.additional_domains : domain.name => domain
  }

  zone_id         = data.cloudflare_zone.dns.id
  name            = each.value.name
  value           = "proxy.${data.cloudflare_zone.dns.name}"
  type            = "CNAME"
  proxied         = each.value.proxied
  allow_overwrite = true
}

resource "cloudflare_record" "forward_proxy" {
  zone_id         = data.cloudflare_zone.dns.id
  name            = "proxy"
  value           = aws_instance.forward_proxy.public_dns
  type            = "CNAME"
  proxied         = false # not supported
  allow_overwrite = true
}

resource "cloudflare_record" "cdn" {
  zone_id         = data.cloudflare_zone.dns.id
  name            = aws_s3_bucket.cdn.id
  value           = aws_cloudfront_distribution.cdn.domain_name
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "cdn_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cdn.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.cloudflare_zone.dns.id
  name            = each.value.name
  value           = each.value.record
  type            = each.value.type
  ttl             = 60    # seconds
  proxied         = false # not supported
  allow_overwrite = true
}

resource "cloudflare_record" "b2" {
  zone_id         = data.cloudflare_zone.dns.id
  name            = "b2"
  value           = trimprefix(data.b2_account_info.current.download_url, "https://")
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}
