terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  credentials = var.credentials_path
  project     = var.project_id
  region      = var.region
}

provider "google-beta" {
  alias       = "beta"
  credentials = var.credentials_path
  project     = var.project_id
  region      = var.region
}