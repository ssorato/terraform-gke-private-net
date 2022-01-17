variable "project_id" {
  type        = string
  description = "GCP project id"
}

variable "credentials" {
  type        = string
  description = "The GCP service account credentials"
}

variable "region" {
  type        = string
  description = "GCP region"
  default     = "us-central1"
}

variable "gke_name" {
  type        = string
  description = "The name of the GKE cluster"
  default     = "gke-demo"
}

variable "gke_num_nodes" {
  type        = number
  description = "The number of nodes per instance group"
  default     = 1
}

variable "node_disk_size_db" {
  type        = number
  description = "Size of the disk attached to each node"
  default     = 10
}

variable "node_disk_type" {
  type        = string
  description = "Type of the disk attached to each node"
  default     = "pd-standard"
}

variable "cluster_version" {
  type        = string
  description = "The Kubernetes version"
  default     = "1.16"
}

variable "maintenance_start_time" {
  type        = string
  description = "Time window specified for daily maintenance operations"
  default     = "03:00"
}

variable "master_ip_cidr_range" {
  type        = string
  description = "The master node ip cidr"
  default     = "10.100.100.0/28"
}

variable "pods_ip_cidr_range" {
  type        = string
  description = "The pods ip cidr"
  default     = "10.101.0.0/16"
}

variable "services_ip_cidr_range" {
  type        = string
  description = "The pods ip cidr"
  default     = "10.102.0.0/16"
}

variable "node_machine_type" {
  type        = string
  description = "The type of node machine"
  default     = "e2-micro"
}

variable "node_preemptible" {
  type        = bool
  description = "Set if machine node is preemptible"
  default     = true
}

variable "gke_region" {
  type        = string
  description = "The location (region or zone) of the cluster"
  default     = "us-central1-a"
}

variable "node_locations" {
  type        = list(string)
  description = "The list of zones in which the node pool's nodes should be located"
  default     = ["us-central1-a"]
}

variable "subnet_cidr" {
  type        = string
  description = "The subnet cidr"
  default     = "10.10.0.0/24"
}

variable "common_labels" {
  type        = map(string)
  description = "Common labels"
  default     = {
      terraform   = "terraform-module-gcp"
  }
}

variable "app_domain" {
  type        = string
  description = "Sample application domain"
  default     = ""
}