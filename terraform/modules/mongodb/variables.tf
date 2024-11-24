variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet for MongoDB"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for MongoDB instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for MongoDB"
  type        = string
  default     = "t3.medium"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR blocks allowed to SSH to MongoDB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "mongodb_username" {
  description = "MongoDB admin username"
  type        = string
  default     = "admin"
}

variable "mongodb_password" {
  description = "MongoDB admin password"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Name of the MongoDB database"
  type        = string
  default     = "plantasia"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
} 