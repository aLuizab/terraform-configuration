variable "aws_region" {
  default = "us-east-2"
}

variable "environment" {
  default = "primbot-develop"
}

variable "vpc_cidr" {
  default     = "172.0.0.0/16"
  description = "CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(any)
  default     = ["172.0.1.0/24", "172.0.2.0/24", "172.0.3.0/24"]
  description = "CIDR block for Public Subnet"
}