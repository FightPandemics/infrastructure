# Create IAM and Bucket policies
data "aws_iam_policy_document" "s3_pol" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.oai.iam_arn}"]
    }
    resources = ["${aws_s3_bucket.cdn.arn}/*"]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    principals {
      type = "AWS"
      identifiers = [data.aws_iam_role.web_server_ecs_execution_role.arn]
    }

    resources = ["${aws_s3_bucket.cdn.arn}/*"]
  }
}

data "aws_iam_role" "web_server_ecs_execution_role" {
  name = "ecs-task-execution"
}

resource "aws_s3_bucket_policy" "atch_s3_pol_attach" {
  bucket = aws_s3_bucket.cdn.id
  policy = data.aws_iam_policy_document.s3_pol.json
}
