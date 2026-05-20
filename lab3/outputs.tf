output "frontend_public_ip" {
  description = "Publiczny adres IP instancji Frontend"
  value       = aws_instance.frontend_instance.public_ip
}

output "backend_public_ip" {
  description = "Publiczny adres IP instancji Backend"
  value       = aws_instance.backend_instance.public_ip
}

output "frontend_url" {
  description = "URL do aplikacji Frontend w przeglądarce"
  value       = "http://${aws_instance.frontend_instance.public_ip}"
}

output "backend_url" {
  description = "URL do API Backend"
  value       = "http://${aws_instance.backend_instance.public_ip}:8080"
}