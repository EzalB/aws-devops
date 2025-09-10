resource "aws_s3_bucket" "s3_bucket" {
  bucket_prefix = var.bucket_prefix
  force_destroy = var.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  count  = var.enable_lifecycle_rule ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    id     = "lifecycle-rule"
    status = "Enabled"

    filter {
      prefix = ""
    }

    # Transition objects to a different storage class
    transition {
      days          = var.lifecycle_rule_days
      storage_class = var.transition_storage_class
    }

    # Expire objects after N days
    expiration {
      days = var.expiration_days
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls        = var.block_public_acls
  block_public_policy      = var.block_public_policy
  ignore_public_acls       = var.ignore_public_acls
  restrict_public_buckets  = var.restrict_public_buckets
}