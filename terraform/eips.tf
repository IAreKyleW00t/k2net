##
# Elastic IPs
##
resource "aws_eip" "forward_proxy" {
  instance                  = aws_instance.forward_proxy.id
  associate_with_private_ip = aws_instance.forward_proxy.private_ip

  tags = merge(local.tags, {
    Name = "forward-proxy"
  })
}

resource "aws_eip" "pihole" {
  instance                  = aws_instance.pihole.id
  associate_with_private_ip = aws_instance.pihole.private_ip

  tags = merge(local.tags, {
    Name = "pihole"
  })
}
