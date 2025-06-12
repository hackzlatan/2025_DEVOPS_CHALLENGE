module "network" {
  source = "./modules/network"
  region = var.region
}

#module "gke" {
#  source     = "./modules/gke"
#  region     = var.region
#  network    = module.network.network_name
#  subnetwork = module.network.subnetwork_name
#}
