# Compression bucket
resource "aws_s3_bucket" "compression_bucket" {
  bucket = "hfmsune-compression-bucket"

  tags = {
    environment = ""
  }
}

resource "aws_s3_bucket" "user_data_bucket" {
  bucket = "hfmsune-user-data-bucket"

  tags = {
    environment = ""
  }
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