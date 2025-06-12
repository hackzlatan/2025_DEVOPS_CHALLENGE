output "cluster_name" {
  value = google_container_cluster.autopilot.name
}

output "cluster_endpoint" {
  value = google_container_cluster.autopilot.endpoint
}
