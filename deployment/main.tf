provider "aws" {
  region = "us-east-1" # Adjust region as needed
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })
}

# Attach Basic Execution Role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Proxy Lambda Function
resource "aws_lambda_function" "proxy_lambda" {
  function_name = "proxy_lambda"
  runtime       = "python3.9"
  handler       = "proxy_handler.lambda_handler"
  filename      = "proxy_lambda.zip"
  role          = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("proxy_lambda.zip")
}

# Add Function URL for Proxy Lambda
resource "aws_lambda_function_url" "proxy_lambda_url" {
  function_name = aws_lambda_function.proxy_lambda.function_name
  authorization_type = "NONE" # Change to "AWS_IAM" for secured access
}

# Text Recognition Lambda Function
resource "aws_lambda_function" "text_recognition_lambda" {
  function_name = "text_recognition_lambda"
  runtime       = "python3.9"
  handler       = "text_handler.lambda_handler"
  filename      = "text_recognition_lambda.zip"
  role          = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("text_recognition_lambda.zip")
}

# Add Function URL for Text Recognition Lambda
resource "aws_lambda_function_url" "text_recognition_lambda_url" {
  function_name = aws_lambda_function.text_recognition_lambda.function_name
  authorization_type = "NONE" # Change to "AWS_IAM" for secured access
}

# API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "Lambda HTTP API"
  protocol_type = "HTTP"
}

# Integration for Proxy Lambda
resource "aws_apigatewayv2_integration" "proxy_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.proxy_lambda.invoke_arn
  payload_format_version = "2.0"
}

# Integration for Text Recognition Lambda
resource "aws_apigatewayv2_integration" "text_recognition_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.text_recognition_lambda.invoke_arn
  payload_format_version = "2.0"
}

# Route for Proxy Lambda
resource "aws_apigatewayv2_route" "proxy_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /proxy"
  target    = "integrations/${aws_apigatewayv2_integration.proxy_integration.id}"
}

# Route for Text Recognition Lambda
resource "aws_apigatewayv2_route" "text_recognition_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /text-recognition"
  target    = "integrations/${aws_apigatewayv2_integration.text_recognition_integration.id}"
}

# Deploy API Gateway
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "prod"
  auto_deploy = true
}

# Outputs for API Endpoints
output "proxy_lambda_endpoint" {
  value = "${aws_apigatewayv2_api.http_api.api_endpoint}/proxy"
  description = "API Endpoint for Proxy Lambda"
}

output "text_recognition_endpoint" {
  value = "${aws_apigatewayv2_api.http_api.api_endpoint}/text-recognition"
  description = "API Endpoint for Text Recognition Lambda"
}


# Outputs to Get URLs
output "proxy_lambda_url" {
  value = aws_lambda_function_url.proxy_lambda_url.function_url
  description = "URL for Proxy Lambda"
}

output "text_recognition_lambda_url" {
  value = aws_lambda_function_url.text_recognition_lambda_url.function_url
  description = "URL for Text Recognition Lambda"
}
