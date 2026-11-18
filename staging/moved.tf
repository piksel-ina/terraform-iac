moved {
  from = module.s3_bucket.aws_s3_bucket.public
  to   = module.s3_bucket.aws_s3_bucket.public_data[0]
}

moved {
  from = module.s3_bucket.aws_s3_bucket_ownership_controls.public_ownership
  to   = module.s3_bucket.aws_s3_bucket_ownership_controls.public_data[0]
}

moved {
  from = module.s3_bucket.aws_s3_bucket_public_access_block.public_access
  to   = module.s3_bucket.aws_s3_bucket_public_access_block.public_data[0]
}

moved {
  from = module.s3_bucket.aws_s3_bucket_acl.public
  to   = module.s3_bucket.aws_s3_bucket_acl.public_data[0]
}

moved {
  from = module.s3_bucket.aws_s3_bucket_cors_configuration.public
  to   = module.s3_bucket.aws_s3_bucket_cors_configuration.public_data[0]
}

moved {
  from = module.s3_bucket.aws_s3_bucket_policy.public_read_policy
  to   = module.s3_bucket.aws_s3_bucket_policy.public_data[0]
}

moved {
  from = module.s3_bucket.aws_s3_bucket_lifecycle_configuration.public
  to   = module.s3_bucket.aws_s3_bucket_lifecycle_configuration.public_data[0]
}

moved {
  from = module.s3_bucket.aws_s3_bucket_website_configuration.public
  to   = module.s3_bucket.aws_s3_bucket_website_configuration.public_data[0]
}
