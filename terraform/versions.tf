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
      version = "5.30.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.20.0"
    }

    b2 = {
      source  = "backblaze/b2"
      version = "0.8.4"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }

  required_version = "1.6.5"
}
