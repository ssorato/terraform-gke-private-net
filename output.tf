output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "kubernetes_cluster_region" {
  value       = google_container_cluster.primary.location
  description = "GKE Cluster region"
}

output "lb_extenal_ip" {
  value       = google_compute_global_address.lb_external_ip.address
  description = "The load balancer external IP"
}