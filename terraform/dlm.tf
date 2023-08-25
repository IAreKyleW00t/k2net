##
# EBS Snapshots
##
resource "aws_dlm_lifecycle_policy" "snapshots" {
  description        = "${var.vpc_name} - Daily Snapshots"
  execution_role_arn = aws_iam_role.dlm_lifecycle.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "1 week of daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["06:35"] # UTC
      }

      retain_rule {
        count = 7 # days
      }

      tags_to_add = merge(local.tags, {
        SnapshotCreator = "DLM"
      })

      copy_tags = true
    }

    target_tags = {
      Snapshot = "${var.vpc_name}/true"
    }
  }

  tags = merge(local.tags, {
    Name = "${var.vpc_name}-lifecycle-policy"
  })
}
