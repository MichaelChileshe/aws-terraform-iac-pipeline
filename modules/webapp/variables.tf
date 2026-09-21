variable "project_name" {
  description = "Name prefix for resources"
  type        = string
}
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}
variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}
variable "ami_id" {
  description = "AMI id for the web server"
  type        = string
}
variable "admin_cidr" {
  description = "CIDR allowed to SSH"
  type        = string
}
