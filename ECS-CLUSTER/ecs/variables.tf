variable "subnets" {
  description = "Subnets for the ECS services"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the ECS services"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-1"
}

variable "repository_url" {
  description = "Security group ID for the ECS services"
  type        = string
}


