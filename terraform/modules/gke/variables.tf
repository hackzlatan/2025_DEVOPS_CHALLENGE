# Variables for GKE Autopilot cluster
variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "region" {
  description = "GCP region for the cluster"
  type        = string
}
variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}
variable "network" {
  description = "VPC network to deploy the cluster into"
  type        = string
}
variable "subnetwork" {
  description = "Subnetwork to deploy the cluster into"
  type        = string
}
variable "master_ipv4_cidr_block" {
  description = "CIDR block for the private control plane endpoint"
  type        = string
}