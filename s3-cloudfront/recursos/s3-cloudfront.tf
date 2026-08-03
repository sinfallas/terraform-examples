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
  default     = "us-west-1"
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
  bucket                  = aws_s3_bucket.mi_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "sitio_web" {
  bucket = aws_s3_bucket.mi_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.s3name}-oac"
  description                       = "OAC para el S3 ${var.s3name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  s3_origin_id = "miS3Origin"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name              = aws_s3_bucket.mi_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  default_root_object = "index.html"
  is_ipv6_enabled = true                   # IPv6 ON
  http_version    = "http2and3"            # Habilitar HTTP/3
  price_class     = "PriceClass_100"       # Solo Norteamérica y Europa

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    compress         = true                # Comprimir objetos automáticamente
    viewer_protocol_policy = "allow-all"   # HTTP and HTTPS

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  custom_error_response {
    error_code            = 400
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 403
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.mi_bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "permitir_cloudfront" {
  bucket = aws_s3_bucket.mi_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.mi_bucket.bucket
  description = "El nombre del bucket S3."
}

output "cloudfront_url" {
  value       = aws_cloudfront_distribution.cdn.domain_name
  description = "La URL pública generada por CloudFront."
}

output "cloudfront_id" {
  value       = aws_cloudfront_distribution.cdn.id
  description = "El ID de la distribución CloudFront (necesario para invalidar caché)."
}
