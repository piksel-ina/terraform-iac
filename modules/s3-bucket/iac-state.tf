resource "aws_s3_bucket" "iac_state" {
  count = var.create_iac_state ? 1 : 0

  bucket        = "${local.prefix}-iac-state"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

  tags = var.default_tags
}

resource "aws_s3_bucket_versioning" "iac_state" {
  count = var.create_iac_state ? 1 : 0

  bucket = aws_s3_bucket.iac_state[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "iac_state" {
  count = var.create_iac_state ? 1 : 0

  bucket = aws_s3_bucket.iac_state[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "iac_state" {
  count = var.create_iac_state ? 1 : 0

  bucket                  = aws_s3_bucket.iac_state[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "iac_state" {
  count = var.create_iac_state ? 1 : 0

  bucket = aws_s3_bucket.iac_state[0].id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.iac_state_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_policy" "iac_state" {
  count = var.create_iac_state ? 1 : 0

  bucket = aws_s3_bucket.iac_state[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyNonTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.iac_state[0].arn,
          "${aws_s3_bucket.iac_state[0].arn}/*",
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      },
      {
        Sid       = "DenyDeleteBucket"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:DeleteBucket"
        Resource  = aws_s3_bucket.iac_state[0].arn
      },
    ]
  })
}
