data "http" "myip"{
  url = "https://ifconfig.me"
}

resource "google_compute_firewall" "allow-internal" {
  project     = var.project_id
  name        = "${google_compute_network.vpc.name}-allow-internal"
  network     = google_compute_network.vpc.name
  description = "Allow internal traffic on the gke network"

  source_ranges = [var.subnet_cidr]

  allow {
    protocol  = "all"
    ports     = []
  }

  priority = 10
  target_tags = ["${google_compute_network.vpc.name}-allow-internal"]
}

resource "google_compute_firewall" "gke_api" {
  project     = var.project_id
  name        = "gke-api"
  network     = google_compute_network.vpc.name
  description = "Allow access to the GKE API"

  source_ranges = ["${chomp(data.http.myip.body)}/32"]

  allow {
    protocol  = "tcp"
    ports     = ["6443"]
  }

  priority = 10
  target_tags = ["gke-api"]
}