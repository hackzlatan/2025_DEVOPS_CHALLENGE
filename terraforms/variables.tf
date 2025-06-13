# Root-level variables
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region (e.g. southamerica-west1)"
  type        = string
}

variable "vpc_name" {
  description = "Name of the custom VPC"
  type        = string
  default     = "la-vpc"
}

variable "subnet_name" {
  description = "Name of the private subnet"
  type        = string
  default     = "la-subnet-private"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/22"
}

variable "pods_cidr" {
  description = "CIDR range for Pods secondary IP range"
  type        = string
  default     = "10.0.1.0/24"
}

variable "services_cidr" {
  description = "CIDR range for Services secondary IP range"
  type        = string
  default     = "10.0.2.0/24"
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for private control plane endpoint"
  type        = string
  default     = "10.0.3.0/28"
}

variable "router_name" {
  description = "Name of the Cloud Router"
  type        = string
  default     = "la-router"
}

variable "nat_ip_name" {
  description = "Name of the static IP for Cloud NAT"
  type        = string
  default     = "la-nat-ip"
}

variable "nat_name" {
  description = "Name of the Cloud NAT"
  type        = string
  default     = "la-nat"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "la-gke"
}

variable "credentials_path" {
  description = "Ruta del archivo de credenciales"
  type        = string
}
