data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda_fn_zip" {
  type        = "zip"
  source_dir = "${path.cwd}/../"
  output_path = "${var.env}-user_picture_compressor_fn.zip"
  excludes = ["infra"]
}

resource "aws_s3_object" "lambda_fn_zip" {
  bucket = data.aws_s3_bucket.lambda_bucket.id

  key    = "${var.env}-user_picture_compressor_fn.zip"
  source = data.archive_file.lambda_fn_zip.output_path

  etag = filemd5(data.archive_file.lambda_fn_zip.output_path)
}

resource "aws_lambda_function" "user_picture_compressor_lambda" {
  function_name = "user_picture_compressor"

  s3_bucket = data.aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_fn_zip.key

  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.lambda_fn_zip.output_base64sha256

  runtime = "nodejs18.x"

  environment {
    variables = {
      // TODO: Use imported resource
      "DEST_BUCKET" = "${var.env}-user-data-bucket"
    }
  }
}