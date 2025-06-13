# Instantiate network module
module "network" {
  source                  = "./modules/network"
  project_id              = var.project_id
  region                  = var.region
  vpc_name                = var.vpc_name
  subnet_name             = var.subnet_name
  subnet_cidr             = var.subnet_cidr
  pods_cidr               = var.pods_cidr
  services_cidr           = var.services_cidr
  master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  router_name             = var.router_name
  nat_ip_name             = var.nat_ip_name
  nat_name                = var.nat_name
}

# Instantiate GKE module, using google-beta provider
module "gke" {
  source                 = "./modules/gke"
  providers = {
    google = google
    google-beta = google-beta
  }
  project_id             = var.project_id
  region                 = var.region
  cluster_name           = var.cluster_name
  network                = module.network.network_id
  subnetwork             = module.network.subnet_id
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
}
