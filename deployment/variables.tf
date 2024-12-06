variable "region" {
  default = "us-east-1"
}

variable "proxy_lambda_s3_bucket" {
  description = "S3 bucket to store Proxy Lambda zip"
}

variable "text_lambda_s3_bucket" {
  description = "S3 bucket to store Text Recognition Lambda zip"
}

variable "proxy_lambda_s3_key" {
  description = "S3 key for Proxy Lambda zip"
}

variable "text_lambda_s3_key" {
  description = "S3 key for Text Recognition Lambda zip"
}
