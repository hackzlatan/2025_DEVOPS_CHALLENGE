# 🎯 Create a GKE Autopilot cluster with private nodes and secure networking
resource "google_container_cluster" "autopilot" {
  
  # ⚠️ Required to use features only available in the Google Beta provider
  provider = google-beta

  # 🔧 Basic configuration
  project  = var.project_id                  # GCP project ID where the cluster will be deployed
  name     = var.cluster_name                # Name of the GKE cluster
  location = var.region                      # Region where the cluster will be deployed

  # 🚀 Enable Autopilot mode (Google manages node infrastructure)
  enable_autopilot = true

  # 🛡️ Use the STABLE release channel for slow, safe, production-grade updates
  release_channel {
    channel = "STABLE"
  }

  # 🌐 Specify the VPC network and subnetwork where the cluster will be deployed
  network    = var.network
  subnetwork = var.subnetwork

  # 🧱 Define IP ranges for Pods and Services using alias IPs (VPC-native)
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"      # Secondary range for Pod IPs
    services_secondary_range_name = "services"  # Secondary range for ClusterIP Services
  }

  # 🔐 Configure private cluster settings
  private_cluster_config {
    enable_private_nodes    = true   # Nodes will NOT have public IPs (more secure)
    enable_private_endpoint = false  # API server endpoint remains public (but IAM-secured). If I change this, I could access only with a VPN, bastión o Direct Interconnect
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block  # Reserved range for control plane to connect privately
  }

  # 🌍 Enable HTTP(S) Load Balancer support via built-in Ingress controller
  addons_config {
    http_load_balancing {
      disabled = false  # Keep the addon enabled (default) to support Ingress resources
    }
  }
}
