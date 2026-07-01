output "api_invoke_url" {
  description = "Base URL for the API"
  value       = "${aws_apigatewayv2_api.http.api_endpoint}/movers"
}

output "site_bucket_name" {
  description = "S3 bucket to sync the frontend build into (aws s3 sync ./dist s3://<bucket> --delete)."
  value       = aws_s3_bucket.site.bucket
}

output "website_endpoint" {
  description = "Public URL of the S3-hosted Vue site."
  value       = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}"
}

output "dynamodb_table_name" {
  description = "Name of the movers table."
  value       = aws_dynamodb_table.movers.name
}

output "cron_function_name" {
  description = "Name of the cron Lambda."
  value       = aws_lambda_function.cron.function_name
}

output "movers_function_name" {
  description = "Name of the read (API) Lambda."
  value       = aws_lambda_function.movers.function_name
}