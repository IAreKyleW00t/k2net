terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "k2net"

    workspaces {
      name = "k2net"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.22.0"
    }

    b2 = {
      source  = "backblaze/b2"
      version = "0.8.9"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.4.1"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }

  required_version = "1.6.6"
}
