resource "aws_iam_policy" "workflow_plan_test" {
  name        = "piksel-tf-workflow-plan-test"
  description = "Temporary — verifies PR plan comment rendering. Safe to remove."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Deny"
      Action   = "*"
      Resource = "*"
    }]
  })
  tags = var.default_tags
}
