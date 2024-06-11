variable "vpc_name" {
  description = "The Name of the VPC."
  type        = string
  default     = "VodaFone-VPC"
}

variable "availability_zones" {
  description = "The availability zone to deploy the subnets"
  type        = list(string)
  default     = ["us-west-1a", "us-west-1c"]
}

variable "public_subnet_cidr_blocks" {
  description = "The CIDR block for the public subnet."
  type        = list(string)
  default     = ["192.0.0.0/24", "192.0.1.0/24"]
}


variable "private_subnet_cidr_blocks" {
  description = "The CIDR block for the private subnet."
  type        = list(string)
  default     = ["192.0.2.0/24", "192.0.3.0/24"]
}

