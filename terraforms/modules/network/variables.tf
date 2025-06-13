# Variables for VPC, subnetwork, NAT, and firewall
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

variable "master_ipv4_range_name" {
  description = "Name for the VPC peering range for control plane"
  type        = string
  default     = "master-private-range"
}

variable "master_ipv4_cidr_block" {
  description = "IP range for the private control plane (in CIDR)"
  type        = string
  default     = "10.0.1.0/28"
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
  default     = "gke-nat"
}

variable "firewall_control_plane_name" {
  description = "Name of the firewall for control plane traffic"
  type        = string
  default     = "fw-allow-gke-control-plane"
}

variable "control_plane_source_ranges" {
  description = "Source ranges for control plane ingress"
  type        = list(string)
  default     = ["35.191.0.0/16", "130.211.0.0/22"]
}

variable "firewall_internal_name" {
  description = "Name of the firewall for internal traffic"
  type        = string
  default     = "fw-allow-internal"
}