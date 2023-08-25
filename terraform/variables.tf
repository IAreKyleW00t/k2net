##
# General
##
variable "tags" {
  type        = map(string)
  description = "Additional tags to include with all resources"
  default     = {}
}

##
# Admin
##
variable "admin_email" {
  type        = string
  description = "Administrator email for certificate validation, notifications, etc."
}

variable "budget_amount" {
  type        = number
  description = "AWS Budget limit (USD)"
  default     = 10
}

variable "budget_alert_threshold" {
  type        = number
  description = "AWS Budget alert threshold (%)"
  default     = 80
}

##
# Netmaker
##
variable "netmaker_access_key" {
  type        = string
  description = "Access Key for Netmaker"
  sensitive   = true
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
  }))
  description = "Additional domain entries to create"
}

##
# VPC
##
variable "vpc_name" {
  type        = string
  description = "Primary VPC name"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC IPv4 CIDR range"
  default     = "10.10.0.0/16"
}

variable "vpc_azs" {
  type        = list(string)
  description = "VPC Availability Zones"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "List of IPv4 CIDRs for private subnets"
  default     = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "List of IPv4 CIDRs for public subnets"
  default     = ["10.10.128.0/20", "10.10.144.0/20", "10.10.160.0/20"]
}

##
# SSH
##
variable "ssh_public_key" {
  type        = string
  description = "SSH public key to include within the VPC for EC2 access"
}

variable "ssh_allowed_ips" {
  type        = list(string)
  description = "List of IPv4 CIDRs to allow SSH access from"
  default     = []
}

##
# EC2
##
variable "ec2_ami" {
  type        = string
  description = "AMI to use when launching EC2 instances (defaults to latest Ubuntu 22.04 LTS)"
  default     = ""
}

##
# Ingress
##
variable "ingress_ports" {
  type = list(object({
    name     = string
    port     = number
    protocol = string
  }))
}
