#1 Create s3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "bunda-bucket"
}

#Creating bucket ACL and ownership controls

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.example.id
  acl    = "public-read"
}

#Create s3 object with public read ACL
#Past line 35 into line 42
resource "aws_s3_object" "html_files" {
# fileset("path", "foldername/*")
# enumerates all the contents from that file or directory
  for_each               = fileset("${path.module}/", "*.html")
  bucket                 = aws_s3_bucket.example.id
  key                    = each.value
  source                 = "${path.module}/${each.key}"
  content_type           = "text/html"
  acl                    = "public-read"
  etag                   = filemd5("${path.module}/${each.key}")
}

resource "aws_s3_object" "jpg_files" {
  for_each               = fileset("${path.module}/", "*.jpg")
  bucket                 = aws_s3_bucket.example.id
  key                    = each.value
  source                 = "${path.module}/${each.key}"
  content_type           = "image/jpg"
  acl                    = "public-read"
  etag                   = filemd5("${path.module}/${each.key}")
}


#s3 static webhosting enabled

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  index_document {
    suffix = "index.html"
  }
  depends_on = [aws_s3_bucket_acl.example] #past depends on acl into static webhosting
}
