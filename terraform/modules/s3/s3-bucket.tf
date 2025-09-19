resource "aws_s3_bucket" "s3_bucket" {
  for_each = { for b in var.buckets : b.name => b }

  bucket        = "${var.name_prefix}-${each.value.name}"
  force_destroy = each.value.force_destroy
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.value.name}"
    Location = each.value.location
  })
}

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = { for b in var.buckets : b.name => b if b.versioning }

  bucket = aws_s3_bucket.s3_bucket[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  for_each = { for b in var.buckets : b.name => b if b.enable_lifecycle_rule }


  bucket = aws_s3_bucket.s3_bucket[each.key].id

  rule {
    id     = "lifecycle-rule"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = each.value.lifecycle_rule_days
      storage_class = each.value.transition_storage_class
    }

    expiration {
      days = each.value.expiration_days
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  for_each = aws_s3_bucket.s3_bucket

  bucket                   = each.value.id
  block_public_acls        = var.block_public_acls
  block_public_policy      = var.block_public_policy
  ignore_public_acls       = var.ignore_public_acls
  restrict_public_buckets  = var.restrict_public_buckets
}