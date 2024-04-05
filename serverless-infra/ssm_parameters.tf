// TODO: Consider nesting these variables under the product name as well.
resource "aws_ssm_parameter" "USER_IMAGES_COMPRESSION_BUCKET" {
  name  = "/${var.env}/USER_IMAGES_COMPRESSION_BUCKET"
  type  = "String"
  value = "${var.env}-compression-bucket"
}

resource "aws_ssm_parameter" "USER_DATA_BUCKET" {
  name  = "/${var.env}/USER_DATA_BUCKET"
  type  = "String"
  value = "${var.env}-user-data-bucket"
}

resource "aws_ssm_parameter" "SIGNED_URL_EXPIRE_SECONDS" {
  name  = "/${var.env}/SIGNED_URL_EXPIRE_SECONDS"
  type  = "String"
  value = "300"
}

resource "aws_ssm_parameter" "DATABASE_URL" {
  name  = "/${var.env}/DATABASE_URL"
  type  = "String"
  value = "DatabaseUrl"
}

resource "aws_ssm_parameter" "MONGODB_DATABASE_NAME" {
  name  = "/${var.env}/MONGODB_DATABASE_NAME"
  type  = "String"
  value = "DatabaseName"
}

resource "aws_ssm_parameter" "MONGODB_USER" {
  name  = "/${var.env}/MONGODB_USER"
  type  = "String"
  value = "SomeValue"
}

resource "aws_ssm_parameter" "MONGODB_PWD" {
  name        = "/${var.env}/MONGODB_PWD"
  description = ""
  type        = "SecureString"
  value       = "DatabasePasswordThisMustBeEncryptedInAWS"
}

resource "aws_ssm_parameter" "MONGODB_MAX_POOL_SIZE" {
  name  = "/${var.env}/MONGODB_MAX_POOL_SIZE"
  type  = "String"
  value = "10"
}