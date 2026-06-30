resource "aws_iam_role" "movers" {
  name               = "${var.project_name}-movers-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "movers_logs" {
  role       = aws_iam_role.movers.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "movers_ddb" {
  statement {
    sid       = "ReadMovers"
    actions   = ["dynamodb:Query"]
    resources = [aws_dynamodb_table.movers.arn]
  }
}

resource "aws_iam_role_policy" "movers_ddb" {
  name   = "${var.project_name}-ddb-query"
  role   = aws_iam_role.movers.id
  policy = data.aws_iam_policy_document.movers_ddb.json
}

resource "aws_lambda_function" "movers" {
  function_name = "${var.project_name}-movers"
  role          = aws_iam_role.movers.arn

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  handler = "movers.handler"
  runtime = var.lambda_runtime
  timeout = 10

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.movers.name
    }
  }
}

resource "aws_cloudwatch_log_group" "movers" {
  name              = "/aws/lambda/${aws_lambda_function.movers.function_name}"
  retention_in_days = 14
}

resource "aws_apigatewayv2_api" "http" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET"]
    allow_headers = ["content-type"]
  }
}

resource "aws_apigatewayv2_integration" "movers" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.movers.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"

}
resource "aws_apigatewayv2_route" "movers" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /movers"
  target    = "integrations/${aws_apigatewayv2_integration.movers.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowInvokeFromHttpApi"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.movers.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}

