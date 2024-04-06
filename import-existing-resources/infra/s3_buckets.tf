data "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.env}-function-code-bucket"
}

// S3 to trigger lambda on object creation
resource "aws_s3_bucket_notification" "compression_bucket_notification" {
  bucket = aws_s3_bucket.compression_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.user_picture_compressor_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "pictures/"
  }
}
