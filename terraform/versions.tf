terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "k2net"

    workspaces {
      name = "k2net"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.52.8"
    }

    b2 = {
      source  = "backblaze/b2"
      version = "0.13.0"
    }
  }

  required_version = "1.15.8"
}
