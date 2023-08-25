##
# Budgets
##
resource "aws_budgets_budget" "monthly" {
  name              = "AWS Monthly Budget"
  budget_type       = "COST"
  limit_amount      = var.budget_amount
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2023-09-01_00:00"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.budget_alert_threshold
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.admin_email]
  }
}
