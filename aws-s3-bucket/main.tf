# Public data bucket
resource "aws_s3_bucket" "public" {
  #checkov:skip=CKV2_AWS_6:Intentionally public bucket. Public access block exists but all values are false by design.
  #checkov:skip=CKV_AWS_20:Public-read ACL by design. Bucket serves public static assets via website hosting.
  #checkov:skip=CKV_AWS_21:No versioning. Data is reproducible static content.
  #checkov:skip=CKV_AWS_18:Access logging to be implemented (TODO).
  #checkov:skip=CKV_AWS_144:No cross-region replication. Not urgent, future reconsider for compliance.
  #checkov:skip=CKV_AWS_145:SSE-S3 encryption sufficient. CMK to be considered for future compliance.
  #checkov:skip=CKV2_AWS_62:No event notifications needed. No downstream consumers.
  bucket = "${lower(var.project)}-${lower(var.environment)}-public-data"

  # Keep the bucket and contents safe!
  force_destroy = false
  lifecycle {
    prevent_destroy = true
  }

  tags = var.default_tags
}

resource "aws_s3_bucket_ownership_controls" "public_ownership" {
  #checkov:skip=CKV2_AWS_65:ACLs required for public-read access. BucketOwnerPreferred enables ACL usage.
  bucket = aws_s3_bucket.public.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  #checkov:skip=CKV_AWS_53:Intentionally public bucket — public ACLs required for website hosting.
  #checkov:skip=CKV_AWS_54:Intentionally public bucket — public policy required for website hosting.
  #checkov:skip=CKV_AWS_55:Intentionally public bucket — public ACLs must not be ignored.
  #checkov:skip=CKV_AWS_56:Intentionally public bucket — public bucket access must not be restricted.
  bucket                  = aws_s3_bucket.public.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "public" {
  depends_on = [
    aws_s3_bucket_ownership_controls.public_ownership,
    aws_s3_bucket_public_access_block.public_access
  ]

  bucket = aws_s3_bucket.public.id
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.public.id
  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  depends_on = [aws_s3_bucket_public_access_block.public_access]

  bucket = aws_s3_bucket.public.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action = [
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:ListBucket",
          "s3:GetBucketLocation",
        ],
        Resource = [
          "${aws_s3_bucket.public.arn}",
          "${aws_s3_bucket.public.arn}/*",
        ],
      },
    ],
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "public" {
  bucket = aws_s3_bucket.public.id

  rule {
    id     = "expire-old-data"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    transition {
      days          = 60
      storage_class = "ONEZONE_IA"
    }

    expiration {
      days = var.lifecycle_expiration_days
    }
  }
}

resource "aws_s3_bucket_website_configuration" "public" {
  bucket = aws_s3_bucket.public.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
