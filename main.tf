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

