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

# Create a s3 bucket to upload function code
variable "lamda_bucket_name" {
  type = string
  default = "function-code-bucket"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lamda_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Create and upload the function code to lambda s3 bucket
resource "aws_s3_bucket_acl" "lambda_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.lambda_bucket]

  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}


data "archive_file" "lambda_fn_zip" {
  type = "zip"

  # Change the name of the folder as per repo name
  source_dir  = "${path.module}/hello-world"
  output_path = "${path.module}/hello-world.zip"
}

resource "aws_s3_object" "lambda_fn_zip" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "hello-world.zip"
  source = data.archive_file.lambda_fn_zip.output_path

  etag = filemd5(data.archive_file.lambda_fn_zip.output_path)
}


