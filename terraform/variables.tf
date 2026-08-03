variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-central-1" # Frankfurt — closest to your target job market
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "gitops-portfolio"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.34"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium" # cheap enough to run for a few days of demoing
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}
