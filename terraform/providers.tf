provider "aws" {
  region = "us-east-2" # Ohio, default
}

provider "aws" {
  region = "us-east-1" # N. Virginia, required for CloudFront ACM certificate
  alias  = "us_east_1"
}

provider "cloudflare" {}
