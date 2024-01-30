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
  default     = ["172.0.1.0/24"]
  description = "CIDR block for Public Subnet"
}
variable "instance_name" {
        description = "Name of the instance to be created"
        default = "primbot-instance"
}

variable "instance_type" {
        default = "t2.micro"
}

variable "ami_id" {
        description = "The AMI to use"
        default = "ami-09694bfab577e90b0"
}

variable "ami_key_pair_name" {
        default = "tf-playground"
}