data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.project_name}-cron-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_ddb" {
  statement {
    sid       = "WriteDailyMover"
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.movers.arn]
  }
}

resource "aws_iam_role_policy" "lambda_ddb" {
  name   = "${var.project_name}-ddb-put"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_ddb.json
}