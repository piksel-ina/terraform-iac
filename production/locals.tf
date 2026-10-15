locals {
  cluster_name = "piksel-production"

  # Public domain for the environment (must be first in the subdomains list).
  subdomains            = ["piksel.big.go.id"]
  public_hosted_zone_id = "Z08561162REF6LC5AY0UM"

  # Shared Cognito Hosted UI domain used by all OAuth clients.
  cognito_auth_domain = "oauth.piksel.big.go.id"

  # Cross-account role in the shared account for OWS CloudFront/Route53.
  odc_cloudfront_crossaccount_role_arn = "arn:aws:iam::686410905891:role/odc-cloudfront-crossaccount-role-production"

  # External public data buckets JupyterHub/Argo/ODC/STAC may read.
  read_external_buckets = [
    "usgs-landsat",
    "copernicus-dem-30m",
    "e84-earth-search-sentinel-data",
    "piksel-staging-public-data",
  ]

  website_csp_hashes = {
    script = [
      "sha256-0MUyFJhUwQbJbxdRddDw1q7CMNQ//leUWFbuI6XcmZo=",
      "sha256-bI2b8zL8P3uzmgy+aB+Lh2ZEf8GRlptjS0Gs3QKMRSM=",
      "sha256-l75NlFdSAwyAIr8HS79hfv4NDLEpCvkAqGGjpbeKw2M=",
    ]
    style = [
      "sha256-1VpqF7JvfWhhKFUN/Wgu7QDcbPzydQkyrlTIeZlgKuA=",
      "sha256-6Px4n3R6/N/JZ0Mksb8L/02vXYuCkSuF4M4+g55H9j8=",
      "sha256-AIsMoEZ2AFYSNPqPHAPTfeQBkBx0uwe/S138h7oBgqk=",
      "sha256-CKxPDFPrKIw2Ht2LdPlIQKnX2JLCPqqfLJvEfltalpY=",
      "sha256-Fs5uL8gxgNPhzxsyazlrOrPlBr99YkLVQPAjy0lCWKo=",
      "sha256-IcqGb0TAbH6mKQhvd8hBx2FAalfysv4UbOSlrgEnNqs=",
      "sha256-Ls5ZNw60cr+qFp+vOMa3XqxqXIeaEJRIW5LVBMg8WpM=",
      "sha256-TS84dZatrtdrL4Urdf9hRCy+KyN1mPKRgZ7aneRogWU=",
      "sha256-biLFinpqYMtWHmXfkA1BPeCY0/fNt46SAZ+BBk5YUog=",
      "sha256-eslHeDkvJNiffFsT711OoAWNr5i7S9CBs7nlwyVzHxo=",
      "sha256-jKE6QZqne5OsrfemNvuLSNoud++NsCOiSlGuIsQns5o=",
      "sha256-kFAIUwypIt04FgLyVU63Lcmp2AQimPh/TdYjy04Flxs=",
      "sha256-mG3x7kPh9Tg2tpVcQvu9qSUpO0QuLZP1E4wDzpTKrMc=",
      "sha256-mMk19IBj9VYyfXJkcfH4OsT3XlIM4Xyk7QkXk3q7OOA=",
      "sha256-oGgninVhefP1RL1F+kvhagCxY4G3ZZjBfXXp6bCjrEM=",
      "sha256-pXWn7Y697QsrJXquMTeNXeI/S2L1yWROlcGv9xY1GDA=",
      "sha256-sDIENtrZwmox3spLJOzzFKFmi3ELZ0v+EkEB+J8SMrA=",
      "sha256-vEnjl3fZTfqdoswyul3Do5nX1Dv6QnCJUKq7QXyWVN8=",
      "sha256-wVdTdG36cUXYw/mx9TBAbE5C5851vdt2ZDXM9Wdfips=",
      "sha256-wfFRBRN9VtnoKyjFp7nESoyL5GicNVcIrkvfmAPxv1s=",
      "sha256-xMg5igwNvbA3rDpJ8MKzJiCrIDz+/ITK8enKfcHA+ZY=",
    ]
  }
}

# test
