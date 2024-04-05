# Compression bucket
resource "aws_s3_bucket" "compression_bucket" {
  bucket = "compression_bucket"

  tags = {
    environment = ""
  }
}

