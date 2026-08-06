resource "aws_s3_bucket" "public_data" {
  #checkov:skip=CKV2_AWS_6:Intentionally public bucket. Public access block exists but all values are false by design.
  #checkov:skip=CKV_AWS_20:Public-read ACL by design.
  #checkov:skip=CKV_AWS_21:No versioning. Data is reproducible static content.
  #checkov:skip=CKV_AWS_144:No cross-region replication.
  #checkov:skip=CKV_AWS_145:SSE-S3 encryption sufficient.
  #checkov:skip=CKV2_AWS_62:No event notifications needed.
  count = var.create_public_data ? 1 : 0

  bucket        = "${local.prefix}-public-data"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

  tags = var.default_tags
}

resource "aws_s3_bucket_ownership_controls" "public_data" {
  #checkov:skip=CKV2_AWS_65:ACLs required for public-read access.
  count = var.create_public_data ? 1 : 0

  bucket = aws_s3_bucket.public_data[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_data" {
  #checkov:skip=CKV_AWS_53:Intentionally public bucket.
  #checkov:skip=CKV_AWS_54:Intentionally public bucket.
  #checkov:skip=CKV_AWS_55:Intentionally public bucket.
  #checkov:skip=CKV_AWS_56:Intentionally public bucket.
  count = var.create_public_data ? 1 : 0

  bucket                  = aws_s3_bucket.public_data[0].id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "public_data" {
  count = var.create_public_data ? 1 : 0

  depends_on = [
    aws_s3_bucket_ownership_controls.public_data,
    aws_s3_bucket_public_access_block.public_data,
  ]

  bucket = aws_s3_bucket.public_data[0].id
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "public_data" {
  count = var.create_public_data ? 1 : 0

  bucket = aws_s3_bucket.public_data[0].id
  cors_rule {
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
    expose_headers = [
      "Content-Length",
      "Content-Range",
      "Content-Encoding",
      "Content-Type",
      "ETag",
      "Accept-Ranges",
      "Last-Modified",
      "Cache-Control",
    ]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_policy" "public_data" {
  count = var.create_public_data ? 1 : 0

  depends_on = [aws_s3_bucket_public_access_block.public_data]

  bucket = aws_s3_bucket.public_data[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:ListBucket",
          "s3:GetBucketLocation",
        ]
        Resource = [
          aws_s3_bucket.public_data[0].arn,
          "${aws_s3_bucket.public_data[0].arn}/*",
        ]
      },
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "public_data" {
  count = var.create_public_data ? 1 : 0

  bucket = aws_s3_bucket.public_data[0].id

  rule {
    id     = "hygiene-and-tiering"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    transition {
      days          = 60
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_website_configuration" "public_data" {
  count = var.create_public_data ? 1 : 0

  bucket = aws_s3_bucket.public_data[0].id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
