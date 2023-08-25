##
# Domains
##
output "public_cdn_domain" {
  value       = local.cdn_domain
  description = "Public domain for CDN"
}

output "additional_domains" {
  value       = [for d in cloudflare_record.domains : d.hostname]
  description = "Additional domains created"
}

##
# Instances
##
output "forward_proxy" {
  description = "Public IP and EBS volumes for the forward_proxy instance"
  value = {
    "public_ip"  = aws_eip.forward_proxy.public_ip,
    "public_dns" = aws_eip.forward_proxy.public_dns,
    "volumes"    = {}
  }
}

output "pihole" {
  description = "Public IP and EBS volumes for the Pi-Hole instance"
  value = {
    "public_ip"  = aws_eip.pihole.public_ip,
    "public_dns" = aws_eip.pihole.public_dns,
    "volumes"    = {}
  }
}
