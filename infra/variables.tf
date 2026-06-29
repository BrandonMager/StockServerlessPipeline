variable "aws_region" {
  description = "AWS region to deploy services to"
  type        = string
  default     = "us-west-1"
}

variable "aws_profile" {
  description = "AWS CLI profile from aws configure"
  type        = string
  default     = null
}

variable "project_name" {
  description = "Name to use as prefix for naming resources"
  type        = string
  default     = "stock-serverless-pipeline"
}

variable "tags" {
  description = "Default tags applied to resources"
  type        = map(string)
  default = {
    Project   = "stock-serverless-pipeline"
    ManagedBy = "terraform"
  }
}

variable "tickers" {
  description = "Watchlist of ticket symbols the cron job gets"
  type        = list(string)
  default     = ["AAPL", "MSFT", "GOOGL", "AMZN", "TSLA", "NVDA"]
}

variable "schedule_expression" {
  description = "EventBridge schedule for cron job (24 hours)"
  type        = string
  default     = "cron(0 23 * * ? *)"
}

variable "lambda_runtime" {
  description = "Runtime for the cron lambda function"
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "market_api_key" {
  type      = string
  sensitive = true
}