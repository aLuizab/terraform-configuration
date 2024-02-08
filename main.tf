provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

locals {
  Name = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  user_data = <<-EOT
    #!/bin/bash
    sudo apt update -y &&
    sudo apt install -y nginx
    echo "Hello World" > /var/www/html/index.html
  EOT
}

#########################################################################
# CRIA UM MODULO EC2 COM TRÊS INSTANCIAS
#########################################################################

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  for_each = toset(["one", "two", "three"])

  name = "instance-${each.key}"

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.ami_key_pair_name
  monitoring             = true
  subnet_id              = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids = [aws_security_group.ec2_secgp.id]

  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}
#########################################################################
# CRIA UM MODULO VPC COM UMA SUBNET PARA CADA AZ
#########################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = "VPC"
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]

}

#########################################################################
# CRIA UM SECURITY GROUP
#########################################################################

resource "aws_security_group" "ec2_secgp" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "primbot-ec2-security-group"
  }
}


