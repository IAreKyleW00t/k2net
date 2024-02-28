##
# General
##
variable "tags" {
  type        = map(string)
  description = "Additional tags to include with all resources"
  default     = {}
}

##
# DNS
#
variable "cloudflare_zone" {
  type        = string
  description = "Cloudflare DNS zone for all domains entries"
}

variable "additional_domains" {
  type = list(object({
    name    = string
    proxied = bool
    type    = string
    value   = string
  }))
  description = "Additional domain entries to create"
}
