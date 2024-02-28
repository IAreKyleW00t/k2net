cloudflare_zone = "kyle2.net"
additional_domains = [
  { name = "unifi", proxied = false, type = "CNAME", value = "home.kyle2.net" },
  { name = "status", proxied = true, type = "CNAME", value = "home.kyle2.net" }
]
