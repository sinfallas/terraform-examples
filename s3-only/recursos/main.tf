terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type        = string
  description = "Región de AWS donde se desplegará la infraestructura"
  default = "us-west-1"
}

variable "s3name" {
  type        = string
  description = "nombre del s3"
}

resource "aws_s3_bucket" "mi_bucket" {
  bucket = var.s3name
  tags = {
    Name = var.s3name
  }
}

resource "aws_s3_bucket_versioning" "versionamiento" {
  bucket = aws_s3_bucket.mi_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cifrado" {
  bucket = aws_s3_bucket.mi_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "acceso_publico" {
  bucket = aws_s3_bucket.mi_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
