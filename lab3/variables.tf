variable "region" {
  description = "Region AWS"
  type        = string
  default     = "us-east-1"
}

variable "zone" {
  description = "Strefa dostępności AWS"
  type        = string
  default     = "us-east-1a"
}

variable "vpc_cidr" {
  description = "CIDR dla VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_zone_cidr" {
  description = "CIDR dla podsieci publicznej"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "Typ instancji EC2"
  type        = string
  default     = "t2.micro" 
}

variable "ssh_key" {
  description = "Nazwa pary kluczy SSH"
  type        = string
  default     = "vockey" 
}

variable "frontend_docker_image" {
  description = "Nazwa obrazu dockerowego dla frontendu"
  type        = string
  default     = "vilstig/frontend:latest"
}

variable "backend_docker_image" {
  description = "Nazwa obrazu dockerowego dla backendu"
  type        = string
  default     = "vilstig/backend:latest"
}