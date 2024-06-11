variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-1"
}
variable "vpc_name" {
  description = "The Name of the VPC."
  type        = string
  default     = "VodaFone-VPC"
}
variable "public_subnet_count" {
  description = "The number of public subnets"
  type        = number
  default     = 2
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_count" {
  description = "The number of private subnets"
  type        = number
  default     = 2
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
}



variable "availability_zones" {
  description = "The availability zones for the subnets"
  type        = list(string)
}