data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/src"
  output_path = "${path.module}/lambda/build/cron.zip"
}

resource "aws_lambda_function" "cron" {
  function_name = "${var.project_name}-cron"
  role          = aws_iam_role.lambda.arn

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  handler = "index.handler"
  runtime = var.lambda_runtime
  timeout = var.lambda_timeout

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.movers.name
      TICKERS        = join(",", var.tickers)
      MARKET_API_KEY = var.market_api_key
    }
  }
}

resource "aws_cloudwatch_log_group" "cron" {
  name              = "/aws/lambda/${aws_lambda_function.cron.function_name}"
  retention_in_days = 14
}