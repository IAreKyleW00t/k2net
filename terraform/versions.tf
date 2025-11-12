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
      version = "5.12.0"
    }

    b2 = {
      source  = "backblaze/b2"
      version = "0.10.0"
    }
  }

  required_version = "1.13.5"
}
