##
# Cloudflare Zones
##
data "cloudflare_zone" "dns" {
  name = var.cloudflare_zone
}

##
# Backblaze Account
##
data "b2_account_info" "current" {}
