terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}


locals {
  availability_zones = ["${var.aws_region}a"]
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "net-gtw" { 
  vpc_id = aws_vpc.vpc.id
  
  tags = { 
    Name = "NET-GTW" } 
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${element(local.availability_zones, count.index)}-public-subnet"
    Environment = "${var.environment}"
  }
}

#EC2
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  for_each = toset(["one", "two", "three"])

  name = "instance-${each.key}"

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.ami_key_pair_name
  monitoring             = true
  vpc_security_group_ids = ["sg-12345678"]
  subnet_id              = "subnet-00f42627daf86c179"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
