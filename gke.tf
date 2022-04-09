resource "google_service_account" "nodepool_serviceaccount" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}


# GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.gke_name
  location = var.gke_region

  remove_default_node_pool = true
  initial_node_count       = 1

  min_master_version = var.cluster_version

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  ip_allocation_policy { # enables IP aliasing
    cluster_ipv4_cidr_block = var.pods_ip_cidr_range
    services_ipv4_cidr_block = var.services_ip_cidr_range
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }

    http_load_balancing {
      disabled = false
    }

    network_policy_config {
        disabled = false
      }
  }

  network_policy {
    enabled = "true"
    provider = "CALICO"
  }

  workload_identity_config {
    identity_namespace = format("%s.svc.id.goog", var.project_id)
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.maintenance_start_time
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "${chomp(data.http.myip.body)}/32"
      display_name = "My external IP"
    }
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes = true
    master_ipv4_cidr_block = var.master_ip_cidr_range
  }

  resource_labels = merge(
    {
      name = "${var.gke_name}",
      environment = "develop"
    },
    var.common_labels
  )

  #tags = ["foo", "bar"]

  lifecycle {
    ignore_changes = [
      min_master_version,
      ip_allocation_policy,
      network,
      subnetwork,
    ]
  }

  vertical_pod_autoscaling {
    enabled = false
  }

}

# Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.gke_region
  cluster    = google_container_cluster.primary.id
  node_count = var.gke_num_nodes

  node_locations = var.node_locations
  version = var.cluster_version


  node_config {
    service_account = google_service_account.nodepool_serviceaccount.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = merge( # Kubernetes node labels ( node selector )
      {
        name = "${google_container_cluster.primary.name}-node-pool",
        environment = "develop"
        cluster = "${google_container_cluster.primary.name}"
      },
      var.common_labels
    )

    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }

    preemptible  = var.node_preemptible
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size_gb
    disk_type = var.node_disk_type

    # tags         = [ # network firewall
    #   "${var.google_compute_network.vpc.name}-allow-internal"
    # ] 

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to node_count, initial_node_count and version
      # otherwise node pool will be recreated if there is drift between what 
      # terraform expects and what it sees
      initial_node_count,
      node_count,
      version
    ]
  }

  management {
    auto_repair = true
    auto_upgrade = false
  }


  upgrade_settings {
    max_surge = 1
    max_unavailable = 0
  }
}
