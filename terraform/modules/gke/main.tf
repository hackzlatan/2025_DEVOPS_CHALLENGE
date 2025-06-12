resource "google_container_cluster" "autopilot" {
  name     = "hello-autopilot"
  location = var.region

  autopilot {
    enabled = true
  }

  network    = var.network
  subnetwork = var.subnetwork

  release_channel {
    channel = "REGULAR"
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
}
