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