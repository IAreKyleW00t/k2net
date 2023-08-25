##
# SSH Keys
##
resource "aws_key_pair" "ssh" {
  key_name   = "${var.vpc_name}-key"
  public_key = var.ssh_public_key
  tags       = local.tags
}
