##
# Secrets
##
resource "aws_secretsmanager_secret" "netmaker_access_key" {
  name                    = "NETMAKER_ACCESS_KEY"
  recovery_window_in_days = 0 # Not _that_ important

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "netmaker_access_key" {
  secret_id     = aws_secretsmanager_secret.netmaker_access_key.id
  secret_string = var.netmaker_access_key
}
