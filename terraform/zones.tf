##
# Cloudflare Zones
##
resource "cloudflare_zone_settings_override" "main" {
  zone_id = data.cloudflare_zone.dns.id

  settings {
    # DNS > Settings
    cname_flattening = "flatten_at_root"

    # SSL/TLS > Overview
    ssl = "strict"

    # SSL/TLS > Edge Certificates
    security_header {
      enabled = false
    }
    min_tls_version          = "1.2"
    opportunistic_encryption = "on"
    tls_1_3                  = "zrt" # 0-RTT
    automatic_https_rewrites = "on"

    # Security > Settings
    security_level = "medium"
    challenge_ttl  = 3600 # 1hr
    browser_check  = "on"

    # Speed > Optimization > Content Optimization
    brotli      = "on"
    early_hints = "on"
    minify {
      js   = "on"
      css  = "on"
      html = "on"
    }

    # Speed > Optimization > Protocol Optimization
    http3    = "on"
    zero_rtt = "on"

    # Caching > Configuration
    cache_level       = "aggressive" # Standard
    browser_cache_ttl = 0            # Respect existing Headers

    # Network
    websockets          = "on"
    ip_geolocation      = "on"
    opportunistic_onion = "on"
  }
}
