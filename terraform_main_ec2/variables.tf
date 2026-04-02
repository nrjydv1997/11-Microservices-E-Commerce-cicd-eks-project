variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_name" {
  description = "VPC Name for out jumphost server"
  type        = string
  default     = "Jumphost-vpc"
}

variable "igw_name" {
  description = "Internet gateway for external traffic"
  type        = string
  default     = "Jumphost-igw"
}

variable "public_subnet1_name" {
  description = "NAme of public subnet 1"
  type        = string
  default     = "public-subnet1"
}

variable "public_subnet2_name" {
  description = "NAme of public subnet 2"
  type        = string
  default     = "public-subnet2"
}

variable "private_subnet1_name" {
  description = "Name of private subnet 1"
  type        = string
  default     = "private-subnet1"
}

variable "private_subnet2_name" {
  description = "Name of private subnet 2"
  type        = string
  default     = "private-subnet2"
}

variable "public_rt_name" {
  description = "Public route table name"
  type        = string
  default     = "public-rt"
}

variable "private_rt_name" {
  description = "Private route table name"
  type        = string
  default     = "private-rt"
}

variable "sg_name" {
  description = "Security froup for our server"
  type        = string
  default     = "jump-server-sg"
}
variable "iam-role" {
  description = "Iam role for jump-server"
  type        = string
  default     = "Jump-server-iam-role"
}

variable "ami_id" {
  description = "AMI_ID for the EC2 instance"
  type        = string
  default     = "ami-051a31ab2f4d498f5"
}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "c7i-flex.large"
}

variable "key_name" {
  description = "EC2 keypair"
  type        = string
  default     = "Devops-Key"
}

variable "instance_name" {
  description = "EC2 Instance name for the jumphost server"
  type        = string
  default     = "Jumphost-server"
}