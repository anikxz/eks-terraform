variable "region" {
  description = "AWS region"
}
variable "profile" {
  description = "AWS profile"
}
variable "cluster_name" {
  description = "Name of the EKS cluster"
}

variable "node_group_name" {
  description = "Name of the EKS node group"
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
}

variable "node_group_desired_capacity" {
  description = "Desired capacity for the EKS node group"
}

variable "node_group_max_capacity" {
  description = "Maximum capacity for the EKS node group"
}

variable "node_group_min_capacity" {
  description = "Minimum capacity for the EKS node group"
}

variable "instance_type" {
  description = "EC2 instance type for the EKS node group"
}

variable "subnet_cidr_a" {
  description = "CIDR block for EKS subnet A"
}

variable "subnet_cidr_b" {
  description = "CIDR block for EKS subnet B"
}

