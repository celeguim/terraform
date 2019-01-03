variable "aws_region" {
  description = "AWS Region"
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "VPC Name"
  default = "My_VPC"
}

variable "az_list" {
  description = "VPC Availability Zones"
  default = ["us-east-1a","us-east-1b"]
}

variable "private_subnet_suffix" {
  description = "Suffix to append to private subnets name"
  default     = "private"
}

variable "private_subnet_list" {
  description = "VPC Private Subnets"
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "public_subnet_list" {
  description = "VPC Public Subnets"
  default = ["10.0.101.0/24","10.0.102.0/24"]
}

variable "tags" {
  type = "map"
  description = "A map of tags to add to all resources"
  default = {
    Environment = "DEV"
    Version = "v2"
  }
}

variable "private_subnet_tags" {
  type = "map"
  description = "Additional tags for the private subnets"
  default = {
    AddTag1 = "AddTag1"
    AddTag2 = "AddTag2"
  }
}
