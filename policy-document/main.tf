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

data "aws_iam_policy_document" "bucket_write_policy_statements" {
  statement {
    sid = "sid001"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::kzf8wkvqu8/*"]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "bucket_write_policy" {
   name        = "terraform-bucket-write-policy"
   description = "This policy was generated using terraform"
   policy = data.aws_iam_policy_document.bucket_write_policy_statements.json
}

resource "aws_iam_role_policy_attachment" "lambda_bucket_write_policy_attachment" {
  role       = "yogi-file-upload-function-role-57gcjlh0"
  policy_arn = aws_iam_policy.bucket_write_policy.arn
}