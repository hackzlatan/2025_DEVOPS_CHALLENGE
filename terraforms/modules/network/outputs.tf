output "network_id" {
  description = "ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "nat_ip" {
  description = "Static IP address used by Cloud NAT"
  value       = google_compute_address.nat_ip.address
}