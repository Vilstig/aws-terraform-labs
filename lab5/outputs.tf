output "alb_dns_name" {
  description = "DNS name Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "frontend_url" {
  description = "URL do aplikacji przez ALB"
  value       = "http://${aws_lb.app_alb.dns_name}/"
}

output "backend_url" {
  description = "Bazowy URL do API przez ALB"
  value       = "http://${aws_lb.app_alb.dns_name}/chat"
}

output "s3_bucket_name" {
  description = "Nazwa bucketa S3 do przechowywania obrazów"
  value       = aws_s3_bucket.chat_images.bucket
}

output "dynamodb_table_name" {
  description = "Nazwa tabeli DynamoDB do historii czatów"
  value       = aws_dynamodb_table.chat_history.name
}

