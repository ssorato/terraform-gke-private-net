# Global addresses are used for HTTP(S) load balancing.
resource "google_compute_global_address" "lb_external_ip" {
  name          = "lb-external-ip"
  ip_version    = "IPV4"
  address_type  = "EXTERNAL"
  project       = var.project_id
}
