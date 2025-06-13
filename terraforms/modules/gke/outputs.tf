# Export cluster endpoint and status
output "cluster_endpoint" {
  description = "Private endpoint of the GKE control plane"
  value       = google_container_cluster.autopilot.endpoint
}
output "cluster_status" {
  description = "Current status of the GKE cluster"
  value       = google_container_cluster.autopilot.status
}

##### main.tf #####
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
provider "google" {
  project = var.project_id
  region  = var.region
}