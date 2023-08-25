##
# Templates
##
data "template_file" "cloudfront_s3_policy" {
  template = file("${path.module}/policies/cloudfront-s3-policy.json")
  vars = {
    s3_bucket                   = aws_s3_bucket.cdn.arn,
    cloudfront_distribution_arn = aws_cloudfront_distribution.cdn.arn
  }
}

data "template_file" "netmaker_secret_policy" {
  template = file("${path.module}/policies/netmaker-secret-policy.json")
  vars = {
    netmaker_secret_arn = aws_secretsmanager_secret.netmaker_access_key.arn
  }
}

data "template_file" "userdata_netclient" {
  template = file("${path.module}/userdata/netclient.sh")
  vars = {
    aws_region         = local.aws_region
    netmaker_secret_id = aws_secretsmanager_secret.netmaker_access_key.id
  }
}
