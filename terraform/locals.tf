locals {
  # General
  aws_account_id    = data.aws_caller_identity.current.account_id
  aws_account_alias = data.aws_iam_account_alias.current.account_alias
  aws_region        = data.aws_region.current.name
  tags = merge(var.tags, {
    Terraform = "true",
    VPC       = var.vpc_name
  })

  # CDN
  cdn_domain       = "s3.${var.cloudflare_zone}"
  s3_origin_id     = "s3-${aws_s3_bucket.cdn.id}"
  b2_domain        = "b2.${var.cloudflare_zone}"
  b2_public_bucket = "${var.vpc_name}-public"
}
