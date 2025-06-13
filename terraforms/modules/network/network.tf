# Create VPC in custom mode
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Create private subnet with alias IP and secondary ranges
resource "google_compute_subnetwork" "subnet" {
  name                     = var.subnet_name
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  # Define secondary IP ranges for Pods and Services
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

# Reserve IP range for private control plane
resource "google_compute_global_address" "master_private" {
  name          = var.master_ipv4_range_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = tonumber(split("/", var.master_ipv4_cidr_block)[1])
  network       = google_compute_network.vpc.id
}

# Create VPC peering for GKE master
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.master_private.name]
}

# Create Cloud Router for NAT
resource "google_compute_router" "router" {
  name    = var.router_name
  network = google_compute_network.vpc.id
  region  = var.region
}

# Reserve a static IP for NAT egress
resource "google_compute_address" "nat_ip" {
  name   = var.nat_ip_name
  region = var.region
}

# Configure Cloud NAT for private subnet egress
resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_ip.address]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall: allow control plane to connect to nodes
resource "google_compute_firewall" "allow_control_plane" {
  name    = var.firewall_control_plane_name
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["10250"]
  }

  source_ranges = var.control_plane_source_ranges
  direction     = "INGRESS"
  priority      = 1000
}

# Firewall: allow all internal traffic in the subnet
resource "google_compute_firewall" "allow_internal" {
  name    = var.firewall_internal_name
  network = google_compute_network.vpc.name

  allow {
    protocol = "all"
  }

  source_ranges = [var.subnet_cidr]
}
