resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnet" {
  name                     = var.subnet_name
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

resource "google_compute_global_address" "master_private" {
  name          = "master-private-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  #prefix_length = tonumber(split("/", var.master_ipv4_cidr_block)[1])
  prefix_length = 24
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.master_private.name]
}

resource "google_compute_router" "router" {
  name    = var.router_name
  network = google_compute_network.vpc.id
  region  = var.region
}

resource "google_compute_address" "nat_ip" {
  name   = var.nat_ip_name
  region = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "allow_control_plane" {
  name    = "fw-allow-gke-control-plane"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["10250"]
  }
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  direction     = "INGRESS"
  priority      = 1000
}

resource "google_compute_firewall" "allow_internal" {
  name    = "fw-allow-internal"
  network = google_compute_network.vpc.name
  allow {
    protocol = "all"
  }
  source_ranges = [var.subnet_cidr]
}