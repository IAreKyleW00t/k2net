##
# Cloudflare DNS Records
##
resource "cloudflare_record" "domains" {
  for_each = {
    for index, domain in var.additional_domains : domain.name => domain
  }

  zone_id         = data.cloudflare_zone.dns.id
  name            = each.value.name
  content         = each.value.value
  type            = each.value.type
  proxied         = each.value.proxied
  allow_overwrite = true
}

resource "cloudflare_record" "b2" {
  zone_id         = data.cloudflare_zone.dns.id
  name            = "b2"
  content         = trimprefix(data.b2_account_info.current.download_url, "https://")
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}
