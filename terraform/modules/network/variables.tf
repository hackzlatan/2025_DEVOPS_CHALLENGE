variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region (e.g. us-central1)"
  type        = string
}

variable "vpc_name" {
  description = "Name of the custom VPC"
  type        = string
}

variable "subnet_name" {
  description = "Name of the private subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
}

variable "pods_cidr" {
  description = "CIDR range for Pods secondary IP range"
  type        = string
}

variable "services_cidr" {
  description = "CIDR range for Services secondary IP range"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for private control plane endpoint"
  type        = string
}

variable "router_name" {
  description = "Name of the Cloud Router"
  type        = string
}

variable "nat_ip_name" {
  description = "Name of the static IP for Cloud NAT"
  type        = string
}

variable "nat_name" {
  description = "Name of the Cloud NAT"
  type        = string
}