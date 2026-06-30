data "aws_iam_policy_document" "scheduler_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "scheduler" {
  name               = "${var.project_name}-scheduler-role"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume.json
}

data "aws_iam_policy_document" "scheduler_invoke" {
  statement {
    sid       = "InvokeCronLambda"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.cron.arn]
  }
}

resource "aws_iam_role_policy" "scheduler_invoke" {
  name   = "${var.project_name}-scheduler-invoke"
  role   = aws_iam_role.scheduler.id
  policy = data.aws_iam_policy_document.scheduler_invoke.json
}

resource "aws_scheduler_schedule" "daily" {
  name                         = "${var.project_name}-daily"
  schedule_expression          = "cron(0 23 * * ? *)"
  schedule_expression_timezone = "America/Los_Angeles"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.cron.arn
    role_arn = aws_iam_role.scheduler.arn
  }
}