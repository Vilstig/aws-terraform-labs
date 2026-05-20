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

