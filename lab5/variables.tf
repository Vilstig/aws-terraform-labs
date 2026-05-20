variable "region" {
  description = "Region AWS"
  type        = string
  default     = "us-east-1"
}

variable "azs" {
  description = "Dwie strefy dostępności dla publicznych podsieci"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "name_prefix" {
  description = "Prefix dla zasobów"
  type        = string
  default     = "lista5"
}

variable "vpc_cidr" {
  description = "CIDR dla VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "frontend_docker_image" {
  description = "Obraz dockerowy dla frontendu"
  type        = string
  default     = "vilstig/frontend:latest"
}

variable "backend_docker_image" {
  description = "Obraz dockerowy dla backendu"
  type        = string
  default     = "vilstig/backend:latest"
}

variable "frontend_port" {
  description = "Port na którym dostępny jest frontend"
  type        = number
  default     = 3000
}

variable "backend_port" {
  description = "Port na którym dostępny jest backend"
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Ilość tasków dla każdej usługi"
  type        = number
  default     = 1
}

variable "frontend_cpu" {
  description = "CPU dla frontendu"
  type        = number
  default     = 256
}

variable "frontend_memory" {
  description = "Memory dla frontendu"
  type        = number
  default     = 512
}

variable "backend_cpu" {
  description = "CPU dla backendu"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Memory dla backendu"
  type        = number
  default     = 512
}
