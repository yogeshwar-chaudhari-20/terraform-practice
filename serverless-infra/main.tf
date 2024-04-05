terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }    
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "ap-southeast-2"
  default_tags {
    tags = {
      environment = "${var.env}"
    }
  }
}

# Import existing VPC
import {
  to = aws_vpc.default_vpc
  id = "vpc-0eb4e94ab2c8b37a6"
}

resource "aws_vpc" "default_vpc" {
  tags = {
    "Name"  = "marketplace-vpc"
    "owner" = "yogeshwar.chaudhari"
  }
}

data "archive_file" "lambda_fn_zip" {
  type = "zip"

  # Change the name of the folder as per repo name
  source_dir  = "${path.module}/hello-world"
  output_path = "${path.module}/${var.env}-hello-world.zip"
}

resource "aws_s3_object" "lambda_fn_zip" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "${var.env}-hello-world.zip"
  source = data.archive_file.lambda_fn_zip.output_path

  etag = filemd5(data.archive_file.lambda_fn_zip.output_path)
}

# Create lambda function
resource "aws_lambda_function" "hello_world" {
  function_name = "HelloWorld"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_fn_zip.key

  runtime = "nodejs18.x"
  handler = "hello.handler"

  source_code_hash = data.archive_file.lambda_fn_zip.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "hello_world" {
  name = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"

  retention_in_days = 14
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create a IAM policy JSON to allow PutObject, GetObject operations on buckets
data "aws_iam_policy_document" "bucket_access_policy_document" {
  statement {
    sid       = "sid001"
    actions   = ["s3:PutObject", "s3:GetObject"]
    resources = ["arn:aws:s3:::${var.env}-compression-bucket/*"]
    effect    = "Allow"
  }
  statement {
    sid       = "sid002"
    actions   = ["s3:PutObject", "s3:GetObject"]
    resources = ["arn:aws:s3:::${var.env}-user-data-bucket/*"]
    effect    = "Allow"
  }
}

# Create a IAM policy using above JSON statements.
resource "aws_iam_policy" "bucket_access_policy" {
  name        = "bucket_access_policy"
  description = "Policy to allow lambda to create and get object/s from bucket"
  policy      = data.aws_iam_policy_document.bucket_access_policy_document.json
}

# Attaching invoice bucket access policy to Lambda execution role.
resource "aws_iam_role_policy_attachment" "lambda_bucket_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.bucket_access_policy.arn
}

# Fetching the SSM read only policy
data "aws_iam_policy" "AmazonSSMReadOnlyAccess" {
  name = "AmazonSSMReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "lambda_ssm_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = data.aws_iam_policy.AmazonSSMReadOnlyAccess.arn
}
# Lambda has read access to SSM

variable "env" {
  default = "development"
}