# Admin
admin_email   = "admin@kyle2.net"
budget_amount = 20

# Netmaker
# netmaker_access_key = "" # Added at runtime via Terraform Cloud

# DNS
cloudflare_zone = "kyle2.net"
additional_domains = [
  { name = "unifi", proxied = false },
  { name = "vault", proxied = true }
]

# VPC
vpc_name            = "k2net"
vpc_cidr            = "10.10.0.0/16"
vpc_azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
vpc_private_subnets = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
vpc_public_subnets  = ["10.10.128.0/20", "10.10.144.0/20", "10.10.160.0/20"]

# SSH
ssh_public_key  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0WJ0nsg/8xLA41jISzl3d4VKHv3V13y8AY1iUntymD id_ed25519"
ssh_allowed_ips = ["76.177.233.118/32"]

# EC2
ec2_ami = "ami-098a05cb0086adf25" # Ubuntu 22.04 LTS, arm64, 8/22/2023

# Ingress
ingress_ports = [
  {
    name     = "UniFi STUN"
    port     = 3478
    protocol = "udp"
  },
  {
    name     = "UniFi Control"
    port     = 8080
    protocol = "tcp"
  },
  {
    name     = "UniFi API"
    port     = 8443
    protocol = "tcp"
  },
  {
    name     = "UniFi HTTP"
    port     = 8880
    protocol = "tcp"
  },
  {
    name     = "UniFi HTTPS"
    port     = 8843
    protocol = "tcp"
  },
  {
    name     = "UniFi SpeedTest"
    port     = 6789
    protocol = "tcp"
  },
  {
    name     = "UniFi Discovery"
    port     = 10001
    protocol = "udp"
  },
  {
    name     = "UniFi L2 Discovery"
    port     = 1900
    protocol = "udp"
  }
]
