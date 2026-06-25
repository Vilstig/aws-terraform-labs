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

output "sns_topic_arn" {
  description = "ARN tematu SNS dla alarmow CloudWatch"
  value       = aws_sns_topic.alarms.arn
}

output "live_chat_table_name" {
  description = "Nazwa tabeli DynamoDB dla live chatu"
  value       = aws_dynamodb_table.live_chat.name
}

output "messages_table_name" {
  description = "Nazwa tabeli DynamoDB dla wiadomosci z Lambda"
  value       = aws_dynamodb_table.messages.name
}

output "placki_sns_topic_arn" {
  description = "ARN tematu SNS dla powiadomien o wiadomosciach z placki"
  value       = aws_sns_topic.placki_notifications.arn
}

output "api_gateway_url" {
  description = "Bazowy URL API Gateway (stage prod)"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "api_gateway_messages_url" {
  description = "Endpoint POST dla wiadomosci (Lambda)"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/messages"
}
