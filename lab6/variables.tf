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
  default     = "lista6"
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

variable "alarm_email" {
  description = "Adres e-mail do powiadomien SNS z alarmow CloudWatch"
  type        = string
  default     = "280562@student.pwr.edu.pl"
}

variable "cpu_alarm_threshold" {
  description = "Prog alarmu CPU dla serwisow ECS (procent)"
  type        = number
  default     = 80
}

variable "cpu_alarm_evaluation_periods" {
  description = "Liczba okresow ewaluacji dla alarmu CPU"
  type        = number
  default     = 2
}

variable "cpu_alarm_period" {
  description = "Okres probkowania alarmu CPU (sekundy)"
  type        = number
  default     = 60
}

variable "alb_unhealthy_threshold" {
  description = "Prog alarmu UnHealthyHostCount dla target group ALB"
  type        = number
  default     = 1
}

variable "alb_5xx_threshold" {
  description = "Prog alarmu HTTPCode_Target_5XX_Count (suma w okresie)"
  type        = number
  default     = 1
}

variable "alb_alarm_evaluation_periods" {
  description = "Liczba okresow ewaluacji dla alarmow ALB"
  type        = number
  default     = 2
}

variable "alb_alarm_period" {
  description = "Okres probkowania alarmow ALB (sekundy)"
  type        = number
  default     = 60
}

variable "autoscaling_min_capacity" {
  description = "Minimalna liczba taskow ECS przy auto scaling"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maksymalna liczba taskow ECS przy auto scaling"
  type        = number
  default     = 4
}

variable "autoscaling_target_cpu" {
  description = "Docelowe srednie wykorzystanie CPU (procent) dla target tracking"
  type        = number
  default     = 20
}

variable "autoscaling_scale_in_cooldown" {
  description = "Cooldown scale-in (sekundy)"
  type        = number
  default     = 60
}

variable "autoscaling_scale_out_cooldown" {
  description = "Cooldown scale-out (sekundy)"
  type        = number
  default     = 60
}
