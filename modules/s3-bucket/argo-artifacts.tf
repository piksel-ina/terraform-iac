resource "aws_s3_bucket" "argo_artifacts" {
  #checkov:skip=CKV2_AWS_6:No public access block needed. Bucket is private, access controlled via IAM/IRSA only.
  #checkov:skip=CKV_AWS_21:No versioning. Artifacts are reproducible outputs.
  #checkov:skip=CKV_AWS_144:No cross-region replication.
  #checkov:skip=CKV_AWS_145:SSE-S3 encryption sufficient.
  #checkov:skip=CKV2_AWS_62:No event notifications needed.
  count = var.create_argo_artifacts ? 1 : 0

  bucket        = "${local.prefix}-argo-artifacts"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

  tags = var.default_tags
}

resource "aws_s3_bucket_public_access_block" "argo_artifacts" {
  count = var.create_argo_artifacts ? 1 : 0

  bucket                  = aws_s3_bucket.argo_artifacts[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "argo_artifacts" {
  count = var.create_argo_artifacts ? 1 : 0

  bucket = aws_s3_bucket.argo_artifacts[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "argo_artifacts" {
  count = var.create_argo_artifacts ? 1 : 0

  bucket = aws_s3_bucket.argo_artifacts[0].id

  rule {
    id     = "expire-artifacts"
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
