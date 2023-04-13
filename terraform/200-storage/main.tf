locals {
  prefix = lower(var.bucket_name)
}


resource "aws_s3_bucket" "bucket_databricks" {
  bucket = "${local.prefix}-${data.aws_caller_identity.current.account_id}"

}

resource "aws_s3_bucket_acl" "buckten_acl" {
  bucket = aws_s3_bucket.bucket_databricks.id
  acl    = "private"

}

resource "aws_s3_bucket_versioning" "versioning_bucketadb" {
  bucket = aws_s3_bucket.bucket_databricks.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.bucket_databricks.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

resource "aws_s3_bucket_policy" "name" {
  bucket = aws_s3_bucket.bucket_databricks.id
  policy = data.aws_iam_policy_document.adb_grant_access.json

}

data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "adb_grant_access" {

  statement {
    sid = "Grant Databricks Access"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.databricks_account_id}:root"]

    }

    actions = ["s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    "s3:GetBucketLocation"]

    resources = [
      "${aws_s3_bucket.bucket_databricks.arn}",
      "${aws_s3_bucket.bucket_databricks.arn}/*"
    ]
  }
}

