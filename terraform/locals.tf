locals {
  # General
  tags = merge(var.tags, {
    Terraform  = "true",
    Repository = "IAreKyleW00t/k2net"
  })

  # B2
  b2_domain        = "b2.${var.cloudflare_zone}"
  b2_public_bucket = "k2net-public"
  b2_backup_bucket = "k2net-backups"
}
