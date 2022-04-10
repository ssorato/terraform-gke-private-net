resource "google_compute_network" "vpc" {
  name                            = "${var.gke_name}-vpc"
  auto_create_subnetworks         = "false"
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "subnet" {
  name                      = "${var.gke_name}-subnet"
  region                    = var.region
  network                   = google_compute_network.vpc.name
  ip_cidr_range             = var.subnet_cidr
  private_ip_google_access  = true
}

resource "google_compute_route" "egress_internet" {
  name             = "egress-internet"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc.name
  next_hop_gateway = "default-internet-gateway"
}

resource "google_compute_router" "router" {
  name    = "${var.gke_name}-vpc-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc.name
}

resource "google_compute_router_nat" "nat_router" {
  name                               = "${google_compute_subnetwork.subnet.name}-nat-router"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# https://kubernetes.github.io/ingress-nginx/deploy/#gce-gke 
resource "google_compute_firewall" "nginx-ingress-admission" {
  name    = "nginx-ingress-admission"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  target_tags = [ "${google_container_cluster.primary.name}-node-pool-fw-target" ]
}