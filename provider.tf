terraform {
  required_providers {
    google = {
      source      = "google"
      version     = "3.84.0"
    }
    google-beta = {
      source      = "google-beta"
      version     = "3.84.0"
    }
  }
}


provider "google" {
  credentials = "${file(var.credentials)}"
  project     = var.project_id
  region      = var.region
}

provider "google-beta" {
  credentials = "${file(var.credentials)}"
  project     = var.project_id
  region      = var.region
}
