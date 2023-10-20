##
# Security Groups
##
resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allows SSH traffic from specific IPs"
  vpc_id      = module.vpc.vpc_id
  tags = merge(local.tags, {
    Name = "ssh"
  })
}

resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow public HTTP/HTTPS traffic"
  vpc_id      = module.vpc.vpc_id
  tags = merge(local.tags, {
    Name = "web"
  })
}

resource "aws_security_group" "gateway" {
  name        = "gateway"
  description = "Allow public Netclient gateway traffic"
  vpc_id      = module.vpc.vpc_id
  tags = merge(local.tags, {
    Name = "gateway"
  })
}

resource "aws_security_group" "ingress_ports" {
  name        = "ingress-ports"
  description = "Allows additional ports through forward proxy"
  vpc_id      = module.vpc.vpc_id
  tags = merge(local.tags, {
    Name = "ingress-ports"
  })
}

resource "aws_security_group" "dns" {
  name        = "dns"
  description = "Allows DNS traffic within VPC"
  vpc_id      = module.vpc.vpc_id
  tags = merge(local.tags, {
    Name = "dns"
  })
}

##
# Rules
##
resource "aws_security_group_rule" "ssh" {
  count = length(var.ssh_allowed_ips) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_allowed_ips
  security_group_id = aws_security_group.ssh.id
  description       = "SSH"
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
  description       = "HTTP"
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
  description       = "HTTPS"
}

resource "aws_security_group_rule" "wireguard" {
  type              = "ingress"
  from_port         = 51821
  to_port           = 51830
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.gateway.id
  description       = "WireGuard"
}

resource "aws_security_group_rule" "ingress_ports" {
  for_each = {
    for index, port in var.ingress_ports : port.name => port
  }

  type              = "ingress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = each.value.protocol
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ingress_ports.id
  description       = each.value.name
}

resource "aws_security_group_rule" "dns" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = [module.vpc.vpc_cidr_block]
  security_group_id = aws_security_group.dns.id
  description       = "DNS"
}
