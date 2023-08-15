# S3 static website bucket
resource "aws_s3_bucket" "s3-static-website" {
  bucket = var.static-website-name
  tags = {
    Name = var.static-website-name
  }
}

resource "aws_s3_bucket_website_configuration" "s3-static-website-configuration" {
  bucket = aws_s3_bucket.s3-static-website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_versioning" "s3-static-website-bucket-versioning" {
  bucket = aws_s3_bucket.s3-static-website.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket ACL access

resource "aws_s3_bucket_ownership_controls" "s3-static-website-ownership-controls" {
  bucket = aws_s3_bucket.s3-static-website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-static-website-public-access-block" {
  bucket = aws_s3_bucket.s3-static-website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3-static-website-bucket-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3-static-website-ownership-controls,
    aws_s3_bucket_public_access_block.s3-static-website-public-access-block,
  ]

  bucket = aws_s3_bucket.s3-static-website.id
  acl    = "public-read"
}