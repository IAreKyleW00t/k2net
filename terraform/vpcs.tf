##
# VPCs
##
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name                   = var.vpc_name
  cidr                   = var.vpc_cidr
  azs                    = var.vpc_azs
  private_subnets        = var.vpc_private_subnets
  public_subnets         = var.vpc_public_subnets
  create_egress_only_igw = false

  default_security_group_egress = [{
    cidr_blocks = "0.0.0.0/0"
    description = "Allow outbound"
  }]

  tags = local.tags
}
