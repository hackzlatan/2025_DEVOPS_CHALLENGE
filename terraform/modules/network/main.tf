resource "google_compute_network" "main" {
  name                    = "gke-network"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "private" {
  name                     = "gke-subnet-private"
  ip_cidr_range            = "10.0.0.0/28"
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "allow_gke_internal" {
  name    = "fw-allow-gke-internal"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/28"]
  direction     = "INGRESS"
  priority      = 65534
}

resource "google_compute_firewall" "allow_http" {
  name    = "fw-allow-http"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  priority      = 1000
}

/*
# (Opcional) Habilita acceso SSH desde tu IP pública solo si es necesario
resource "google_compute_firewall" "allow_ssh" {
  name    = "fw-allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["TU.IP.PUBLICA.AQUI/32"]
  direction     = "INGRESS"
  priority      = 1000
}
*/