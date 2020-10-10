# Create S3 bucket for cdn.
resource "aws_s3_bucket" "cdn" {
  bucket = "fp-${var.fp_context}-cdn"
  tags = {
    Name = "fp-${var.fp_context}-cdn"
  }
}

# Create S3 bucket for cdn logs.
resource "aws_s3_bucket" "cdn-logs" {
  bucket = "fp-${var.fp_context}-cdn-logs"
  acl    = "private"
  tags = {
    Name = "fp-${var.fp_context}-cdn-logs"
  }
}

# Create Origin Access Identity for CDN-S3.
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "cloudfront origin access identity"
}

/*
# use this code if you have a domain and certificate.
# Find certificate that is issued for the domain
data "aws_acm_certificate" "fp_issued" {
  domain   = "${var.domain}"
  statuses = ["ISSUED"]
}
*/

locals {
  s3_origin_id = "${aws_s3_bucket.cdn.id}-org"
}
# origin - cloudfront get its content.
resource "aws_cloudfront_distribution" "fp_cdn" {
  origin {
    domain_name = aws_s3_bucket.cdn.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Fight Pandemic CDN distribution"
  default_root_object = "index.html"


  # logging cofig
  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.cdn-logs.bucket_domain_name}"
    prefix          = "fpcdn"
  }

  /*
  # use this code if you have a domain and certificate.
  # Alternate domain names if any.
  aliases = ["cdn.${var.domain}"]
 */

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "${var.fp_context}"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  /*
 # to use other certificate:
  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.fp_issued.domain}"
    ssl_support_method  = "sni-only"
  }
*/
}
