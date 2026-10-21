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
      version = "5.28.1"
    }

    b2 = {
      source  = "backblaze/b2"
      version = "0.14.0"
    }
  }

  required_version = "1.16.6"
}
