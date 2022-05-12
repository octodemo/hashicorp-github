
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

resource "aws_s3_bucket" "demo" {
  bucket = "terraform-demo-local-s3"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
  bucket = aws_s3_bucket.demo.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket                  = aws_s3_bucket.demo.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "demo" {
  bucket = aws_s3_bucket_versioning.demo.bucket
  key    = "example.txt"
  source = "example.txt"
}
