# curiousaye

# Text Recognition Service with AWS Lambda

This project implements a serverless Text Recognition Service using AWS Lambda and Terraform. The solution consists of two Lambda functions:

1. **Proxy Lambda**: Handles HTTP requests via an API Gateway, validates the request, and invokes the Text Recognition Lambda.
2. **Text Recognition Lambda**: Processes a base64-encoded image, applies two distinct text recognition methods, and returns the most favorable result based on confidence scores.

---

## Features
- **Proxy Lambda**
  - Triggered by an HTTP POST request through API Gateway.
  - Validates the payload to ensure it contains a base64-encoded image.
  - Invokes the Text Recognition Lambda with the provided image data.

- **Text Recognition Lambda**
  - Implements two text recognition methods (AWS Rekognition and Pytesseract).
  - Compares confidence scores from both methods and selects the best result.
  - Includes optional pre-processing of the input image.

- **Infrastructure as Code**
  - Fully automated deployment using Terraform.

---

## Prerequisites

1. **AWS Account**
   - Ensure you have access to an AWS account with permissions to deploy Lambda functions, API Gateway, and related resources.

2. **Tools Installed**
   - [Terraform](https://www.terraform.io/)
   - Python 3.9 or higher
   - AWS CLI (configured with appropriate credentials)

3. **Image Processing Libraries** (for Text Recognition Lambda):
   - `pytesseract`
   - `Pillow`
   - Ensure these are included in the Lambda deployment package or a Lambda layer.

---

## Deployment Steps

### 1. Clone the Repository
```bash
git clone https://github.com/ajaykatke07/curiousaye.git
cd curiousaye
```

### 2. Prepare the Lambda Deployment Packages

- **Proxy Lambda**: Package the `proxy_lambda.py` file into a ZIP archive.
```bash
zip proxy_lambda.zip proxy_lambda.py
```

- **Text Recognition Lambda**: Package `text_recognition.py` along with dependencies.
```bash
pip install -r requirements.txt -t ./package
cd package
zip -r ../text_recognition_lambda.zip .
cd ..
```

### 3. Upload Lambda Packages to S3

- Replace `<bucket-name>` with your S3 bucket name.
```bash
aws s3 cp proxy_lambda.zip s3://<bucket-name>/proxy_lambda.zip
aws s3 cp text_recognition_lambda.zip s3://<bucket-name>/text_recognition_lambda.zip
```

### 4. Deploy Using Terraform

Update the `variables.tf` file with your S3 bucket name and Lambda ZIP file paths.

- Initialize Terraform:
```bash
terraform init
```

- Plan the deployment:
```bash
terraform plan -var="proxy_lambda_s3_bucket=<bucket-name>" \
              -var="proxy_lambda_s3_key=proxy_lambda.zip" \
              -var="text_lambda_s3_bucket=<bucket-name>" \
              -var="text_lambda_s3_key=text_recognition_lambda.zip"
```

- Apply the configuration:
```bash
terraform apply -var="proxy_lambda_s3_bucket=<bucket-name>" \
               -var="proxy_lambda_s3_key=proxy_lambda.zip" \
               -var="text_lambda_s3_bucket=<bucket-name>" \
               -var="text_lambda_s3_key=text_recognition_lambda.zip"
```

---

## API Testing

### Endpoint
Retrieve the API Gateway endpoint from Terraform output or the AWS Management Console.

### Using `curl`
Send a POST request with a base64-encoded image in the body:
```bash
curl -X POST \
  https://<api-gateway-id>.execute-api.<region>.amazonaws.com/text-recognition \
  -H "Content-Type: application/json" \
  -d '{"base64_image": "<base64-encoded-image-data>"}'
```

### Using Postman
1. Set the request type to POST.
2. Use the API Gateway URL as the endpoint.
3. Set `Content-Type` to `application/json` in headers.
4. Include the following payload in the body:
```json
{
  "base64_image": "<base64-encoded-image-data>"
}
```

---

## Directory Structure
```
.
├── proxy_lambda.py                 # Proxy Lambda code
├── text_recognition.py             # Text Recognition Lambda code
├── requirements.txt                # Python dependencies for Text Recognition Lambda
├── main.tf                         # Terraform configuration file
├── variables.tf                    # Terraform variables
├── outputs.tf                      # Terraform outputs
└── README.md                       # Project documentation
```

---

## Notes
- Ensure the uploaded image's Base64 string size is within Lambda's payload size limit (6 MB for API Gateway).
- Use CloudWatch Logs to debug any issues.
- Add custom IAM policies if additional permissions are needed.

---

## Contributing
Feel free to fork the repository and submit pull requests to enhance the solution.

---

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

