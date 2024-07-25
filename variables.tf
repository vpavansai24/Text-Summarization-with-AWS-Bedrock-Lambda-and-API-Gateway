variable "myregion" {
  description = "The AWS Region"
  type = string
  default = "us-east-1"
}

variable "accountId" {
  description = "The AWS Account ID"
  type = string
}

variable "lambda_function_name" {
  description = "The Name of the AWS Lambda Function"
  type = string
  default = "textSummarize"
}

variable "endpoint_path" {
  description = "The Get Endpoint Path"
  type = string
  default = "reports"
}