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
}
