
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.10.0"
    }
  }
  required_version = "1.1.9"
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_kms_key" "mykey" {
  description         = "This key is used to encrypt bucket objects"
  enable_key_rotation = true
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.2.0"

  bucket = "terraform-demo-s3-module"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

}
