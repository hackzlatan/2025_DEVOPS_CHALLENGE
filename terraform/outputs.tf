output "network_id" {
  description = "ID of the created VPC"
  value       = module.network.network_id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = module.network.subnet_id
}

output "nat_ip_address" {
  description = "Static IP address for NAT egress"
  value       = module.network.nat_ip
}

output "cluster_endpoint" {
  description = "Private endpoint of the GKE control plane"
  value       = module.gke.cluster_endpoint
}