##
# EC2 Instances
#
resource "aws_instance" "forward_proxy" {
  instance_type = "t4g.nano"
  ami           = var.ec2_ami != "" ? var.ec2_ami : data.aws_ami.ubuntu.id
  key_name      = aws_key_pair.ssh.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_read_netmaker_secret.name
  user_data            = data.template_file.userdata_netclient.rendered

  associate_public_ip_address = true
  availability_zone           = module.vpc.azs[0]
  subnet_id                   = module.vpc.public_subnets[0]

  vpc_security_group_ids = [
    data.aws_security_group.default.id,
    aws_security_group.ssh.id,
    aws_security_group.web.id,
    aws_security_group.gateway.id,
    aws_security_group.ingress_ports.id
  ]

  root_block_device {
    encrypted   = true
    volume_size = 16 # GB
    volume_type = "gp3"
    tags = merge(local.tags, {
      Name = "forward-proxy"
    })
  }

  tags = merge(local.tags, {
    Name = "forward-proxy"
  })
}

resource "aws_instance" "pihole" {
  instance_type = "t4g.nano"
  ami           = var.ec2_ami != "" ? var.ec2_ami : data.aws_ami.ubuntu.id
  key_name      = aws_key_pair.ssh.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_read_netmaker_secret.name
  user_data            = data.template_file.userdata_netclient.rendered

  associate_public_ip_address = true
  availability_zone           = module.vpc.azs[0]
  subnet_id                   = module.vpc.public_subnets[0]

  vpc_security_group_ids = [
    data.aws_security_group.default.id,
    aws_security_group.ssh.id,
    aws_security_group.dns.id
  ]

  root_block_device {
    encrypted   = true
    volume_size = 16 # GB
    volume_type = "gp3"
    tags = merge(local.tags, {
      Name     = "pihole-2",
      Snapshot = "${var.vpc_name}/true" # Pi-Hole is installed on main volume
    })
  }

  tags = merge(local.tags, {
    Name = "pihole-2"
  })
}
