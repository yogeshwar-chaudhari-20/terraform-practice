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

# Import existing compression bucket
data "aws_s3_bucket" "compression_bucket" {
  bucket = "${var.env}-compression-bucket"
}

# Import existing user data bucket
data "aws_s3_bucket" "user_data_bucket" {
  bucket = "${var.env}-user-data-bucket"
}

variable "env" {
  default = "development"
}