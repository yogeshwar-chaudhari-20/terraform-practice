# Create a s3 bucket to upload function code

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.env}-function-code-bucket"
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

# Compression bucket
resource "aws_s3_bucket" "compression_bucket" {
  bucket = "${var.env}-compression-bucket"
}

resource "aws_s3_bucket" "user_data_bucket" {
  bucket = "${var.env}-user-data-bucket"
}

resource "aws_s3_bucket_cors_configuration" "user_data_bucket_cors_rule" {
  bucket = aws_s3_bucket.user_data_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
}