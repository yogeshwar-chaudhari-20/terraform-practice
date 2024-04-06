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
  region = "ap-southeast-2"
  default_tags {
    tags = {
      environment = "${var.env}"
    }
  }
}

# Import existing compression bucket

import {
  to = aws_s3_bucket.compression_bucket
  id = "${var.env}-compression-bucket"
}
resource "aws_s3_bucket" "compression_bucket" {
}

# Import existing user data bucket
import {
  to = aws_s3_bucket.user_data_bucket
  id = "${var.env}-user-data-bucket"
}

resource "aws_s3_bucket" "user_data_bucket" {
}

variable "env" {
  default = "development"
}
