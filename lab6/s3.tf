resource "aws_s3_bucket" "chat_images" {
  bucket        = local.s3_bucket_name
  force_destroy = true

  tags = {
    Name = "${var.name_prefix}-chat-images"
  }
}

resource "aws_s3_bucket_public_access_block" "chat_images" {
  bucket = aws_s3_bucket.chat_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "chat_images" {
  bucket = aws_s3_bucket.chat_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "chat_images" {
  bucket = aws_s3_bucket.chat_images.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "chat_images" {
  bucket = aws_s3_bucket.chat_images.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

data "aws_iam_policy_document" "chat_images" {
  statement {
    sid    = "AllowBackendTaskRoleObjectAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [local.ecs_task_role_arn]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = ["${aws_s3_bucket.chat_images.arn}/*"]
  }

  statement {
    sid    = "AllowBackendTaskRoleListBucket"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [local.ecs_task_role_arn]
    }

    actions = ["s3:ListBucket"]

    resources = [aws_s3_bucket.chat_images.arn]
  }
}

resource "aws_s3_bucket_policy" "chat_images" {
  bucket = aws_s3_bucket.chat_images.id
  policy = data.aws_iam_policy_document.chat_images.json

  depends_on = [aws_s3_bucket_public_access_block.chat_images]
}

resource "aws_s3_bucket_cors_configuration" "chat_images" {
  bucket = aws_s3_bucket.chat_images.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET"]
    allowed_origins = ["http://${aws_lb.app_alb.dns_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}
