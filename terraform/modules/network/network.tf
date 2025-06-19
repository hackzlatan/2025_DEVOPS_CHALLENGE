# 🚧 Create a custom VPC network (no automatic subnet creation)
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false  # Prevent GCP from creating default subnets
  routing_mode            = "REGIONAL"  # Route traffic only within the same region (This improve the security and isolation)
}

# 🌐 Create a primary subnet with secondary ranges for Pods and Services
resource "google_compute_subnetwork" "subnet" {
  name                     = var.subnet_name
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr  # Main IP range for the subnet
  private_ip_google_access = true  # Allow access to Google APIs without external IPs

  # 🎯 Secondary range for GKE Pods (Alias IPs) - required for Autopilot (GKE VPC-native)
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  # 🎯 Secondary range for Kubernetes Services (ClusterIP) - required for Autopilot (GKE VPC-native)
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

# 📍 Reserve an internal IP range for private VPC peering (used by GKE control plane) - required for GKE with Autopilot
resource "google_compute_global_address" "master_private" {
  name          = "master-private-range"
  purpose       = "VPC_PEERING"  # Used for peering with Google services
  address_type  = "INTERNAL"
  prefix_length = 24  # Size of the reserved IP block
  network       = google_compute_network.vpc.id
}

# 🔗 Establish private VPC peering with the Service Networking API (Used mainly for connect our VPC with the GKE control plane)
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.master_private.name]
}

#Since the pods don't have a public IP (GKE Autopilot does not allow it), they need to use Cloud NAT + Cloud Router to be able to go online and download the App image.

# 🚦 Create a Cloud Router to route traffic for Cloud NAT (Required)
resource "google_compute_router" "router" {
  name    = var.router_name
  network = google_compute_network.vpc.id
  region  = var.region
}

# 🌐 Reserve an external IP address for the NAT gateway
resource "google_compute_address" "nat_ip" {
  name   = var.nat_ip_name
  region = var.region
}

# 🚪 Configure Cloud NAT to allow outbound internet access for private subnets
resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"  # NAT all traffic from all subnets
}

# 🔐 Firewall rule to allow traffic from the GKE control plane to the nodes
resource "google_compute_firewall" "allow_control_plane" {
  name    = "fw-allow-gke-control-plane"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["10250"]  # Port used by kubelet / control plane communication
  }
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]  # GKE control plane IP ranges
  direction     = "INGRESS"
  priority      = 1000
}

# 🔄 Firewall rule to allow internal communication within the subnet
resource "google_compute_firewall" "allow_internal" {
  name    = "fw-allow-internal"
  network = google_compute_network.vpc.name
  allow {
    protocol = "all"  # Allow all protocols internally (TCP, UDP, ICMP)
  }
  source_ranges = [var.subnet_cidr]  # Only allow traffic from within the subnet
}
