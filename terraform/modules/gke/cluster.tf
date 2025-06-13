# Create GKE Autopilot cluster with private nodes
resource "google_container_cluster" "autopilot" {
  # force this resource to use the beta provider
  provider = google-beta

  project  = var.project_id
  name     = var.cluster_name
  location = var.region

  # Enable Autopilot mode
 enable_autopilot = true

  # Use the stable release channel
  release_channel {
    channel = "STABLE"
  }

  # Network settings
  network    = var.network
  subnetwork = var.subnetwork

  # Define secondary IP ranges for Pods and Services (alias IPs enabled by default)
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Enable private nodes and private control plane
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Enable HTTP load balancing addon
  addons_config {
    http_load_balancing {
      disabled = false
    }
  }
}
