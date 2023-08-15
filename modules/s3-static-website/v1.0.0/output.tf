
# s3 static website url

output "staic-website-url" {
  value = "http://${aws_s3_bucket.s3-static-website.bucket}.s3-website.${var.region}.amazonaws.com"
}