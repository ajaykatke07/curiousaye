provider "aws" {
  region = "us-east-1" # Adjust region as needed
}

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

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "proxy_lambda" {
  function_name = "proxy_lambda"
  runtime       = "python3.9"
  handler       = "handler.lambda_handler"
  filename      = "proxy_lambda.zip"
  role          = aws_iam_role.lambda_exec.arn

  source_code_hash = filebase64sha256("C:\\project\\PeterPark\\Python\\TextRecognitionService\\deployment\\proxy_lambda.zip")

}

resource "aws_lambda_function" "text_recognition_lambda" {
  function_name = "text_recognition_lambda"
  runtime       = "python3.9"
  handler       = "handler.lambda_handler"
  filename      = "text_recognition_lambda.zip"
  role          = aws_iam_role.lambda_exec.arn

  source_code_hash = filebase64sha256("C:\\project\\PeterPark\\Python\\TextRecognitionService\\deployment\\text_recognition_lambda.zip")
}
