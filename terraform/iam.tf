##
# EC2 Instance Profiles
##
resource "aws_iam_instance_profile" "ec2_read_netmaker_secret" {
  name = "tf-${var.vpc_name}-ReadOnly-NetmakerSecret-ec2InstanceProfile"
  role = aws_iam_role.read_netmaker_secret.name

  tags = merge(local.tags, {
    Name = "tf-${var.vpc_name}-ReadOnly-NetmakerSecret-ec2InstanceProfile"
  })
}

##
# IAM Roles
##
resource "aws_iam_role" "dlm_lifecycle" {
  name               = "tf-${var.vpc_name}-ServiceRoleForDLM"
  assume_role_policy = file("policies/dlm-lifecycle-role-policy.json")

  tags = merge(local.tags, {
    Name = "tf-${var.vpc_name}-ServiceRoleForDLM"
  })
}

resource "aws_iam_role" "read_netmaker_secret" {
  name               = "tf-${var.vpc_name}-ReadOnly-NetmakerSecret-Role"
  assume_role_policy = file("policies/netmaker-secret-role-policy.json")

  tags = merge(local.tags, {
    Name = "tf-${var.vpc_name}-ReadOnly-NetmakerSecret-Role"
  })
}

##
# IAM Policies
##
resource "aws_iam_role_policy" "dlm_lifecycle" {
  name   = "tf-${var.vpc_name}-dlm-lifecycle-policy"
  role   = aws_iam_role.dlm_lifecycle.id
  policy = file("policies/dlm-lifecycle-policy.json")
}

resource "aws_iam_role_policy" "read_netmaker_secret" {
  name   = "tf-${var.vpc_name}-ReadOnly-NetmakerSecret-Policy"
  role   = aws_iam_role.read_netmaker_secret.id
  policy = data.template_file.netmaker_secret_policy.rendered
}
