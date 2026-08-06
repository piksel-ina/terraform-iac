resource "aws_s3_bucket" "terria" {
  #checkov:skip=CKV2_AWS_6:No public access block needed. Bucket is private, access controlled via IAM/IRSA only.
  #checkov:skip=CKV_AWS_21:No versioning. Data is reproducible map sharing content.
  #checkov:skip=CKV_AWS_144:No cross-region replication.
  #checkov:skip=CKV_AWS_145:SSE-S3 encryption sufficient.
  #checkov:skip=CKV2_AWS_62:No event notifications needed.
  count = var.create_terria ? 1 : 0

  bucket        = "${local.prefix}-terria"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

  tags = var.default_tags
}

resource "aws_s3_bucket_public_access_block" "terria" {
  count = var.create_terria ? 1 : 0

  bucket                  = aws_s3_bucket.terria[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terria" {
  count = var.create_terria ? 1 : 0

  bucket = aws_s3_bucket.terria[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terria" {
  count = var.create_terria ? 1 : 0

  bucket = aws_s3_bucket.terria[0].id

  rule {
    id     = "expire-old-data"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    expiration {
      days = var.artifact_expiration_days
    }
  }
}
