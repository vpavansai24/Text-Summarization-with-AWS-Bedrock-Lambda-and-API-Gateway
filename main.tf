# Configure the AWS Provider
provider "aws" {
  region  = var.myregion
}

# Fetch information about the current AWS account
data "aws_caller_identity" "current" {}

# Create IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Create IAM Policy for Bedrock and CLoudWatch Logs Access
resource "aws_iam_policy" "bedrock_policy" {
  name        = "lambda_bedrock_policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Attach Policy to IAM Role
resource "aws_iam_role_policy_attachment" "role_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.bedrock_policy.arn
}

# Package Lambda function code
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function_payload.zip"
}

# Create Lambda Function
resource "aws_lambda_function" "example_lambda" {
  function_name = var.lambda_function_name
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  filename      = "lambda_function_payload.zip"
  handler       = "lambda_function.lambda_handler"
  timeout          = 60  # Timeout set to 60 seconds (1 minute)
  source_code_hash = filebase64sha256(data.archive_file.lambda.output_path)

  depends_on = [
    aws_iam_role_policy_attachment.role_policy_attach,
    data.archive_file.lambda
  ]
}

# Create API Gateway REST API
resource "aws_api_gateway_rest_api" "example_api" {
  name        = "summarizeAPI"
  description = "API Gateway for Lambda Integration"
}

# Create API Gateway Resource
resource "aws_api_gateway_resource" "example_resource" {
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = var.endpoint_path
  rest_api_id = aws_api_gateway_rest_api.example_api.id
}

# Create API Gateway Method
resource "aws_api_gateway_method" "example_method" {
  authorization = "NONE"
  http_method   = "ANY"  # Set to ANY to handle all HTTP methods
  resource_id   = aws_api_gateway_resource.example_resource.id
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
}

# Create API Gateway Integration
resource "aws_api_gateway_integration" "example_integration" {
  http_method             = aws_api_gateway_method.example_method.http_method
  resource_id             = aws_api_gateway_resource.example_resource.id
  rest_api_id             = aws_api_gateway_rest_api.example_api.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.example_lambda.invoke_arn

  depends_on = [
    aws_lambda_function.example_lambda
  ]
}


# Grant API Gateway permission to invoke Lambda
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "arn:aws:execute-api:${var.myregion}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.example_api.id}/*/${aws_api_gateway_method.example_method.http_method}${aws_api_gateway_resource.example_resource.path}"
}


# Create API Gateway Deployment
resource "aws_api_gateway_deployment" "example_deployment" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.example_resource.id,
      aws_api_gateway_method.example_method.id,
      aws_api_gateway_integration.example_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_resource.example_resource, aws_api_gateway_method.example_method, aws_api_gateway_integration.example_integration]
}

# Create API Gateway Stage
resource "aws_api_gateway_stage" "example_stage" {
  deployment_id = aws_api_gateway_deployment.example_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  stage_name    = "dev"
}