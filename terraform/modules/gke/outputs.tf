output "cluster_endpoint" {
  description = "Private endpoint of the control plane"
  value       = google_container_cluster.autopilot.endpoint
}