# Provides a GKE cluster on a private network with Terraform

## Enable Google Cloud API

Before create the cluster enable the _Compute Engine API_ and _Kubernetes Engine API_

## Retrieve the access credentials

```bash
$ gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw kubernetes_cluster_region)
```
## Sample terraform.tfvars

```tf
project_id = "YOUR_PROJECT_ID"
credentials = "YOUR_TF_SERVICE_ACCOUNT.json"
region = "us-central1"
gke_name = "gke-demo"
gke_region = "us-central1-a"
cluster_version = "1.20.12-gke.1500"
master_ip_cidr_range = "10.100.100.0/28"
pods_ip_cidr_range = "10.101.0.0/16"
services_ip_cidr_range = "10.102.0.0/16"
gke_num_nodes = 2 # Node per zone - in this example 4 nodes will be created
node_locations = ["us-central1-b","us-central1-c"]
node_machine_type = "e2-small"
node_preemptible  = true
node_disk_size_gb = 10
node_disk_type = "pd-ssd"
subnet_cidr = "10.10.0.0/24"
maintenance_start_time = "03:00"
```

## Save terraform state in a bucket

Create a file `backend.tf`

```tf
terraform {
  backend "gcs" {
    credentials = "your_service_account.json"
    bucket      = "your_bucket_name"
    prefix      = "your_bucket_prefix"
  }
}
```

## Sample application

On you DNS domain register set the FQDN as record type A and IP the `lb-external-ip`

Set the FQDN in the [managed-cert.yml](ingress_demo/managed-cert.yml)

```bash
$ kubectl apply -f ingress_demo/
```

Wait for the Google-managed certificate to finish provisioning ( see `Domain Status/Status` ). This might take up to 60 minutes

```bash
$ kubectl describe managedcertificate gke-demo-cert | grep -A5 "^Status"
```

## About demo_application.tf.DISABLED

Trying to create the previous application with terraform and _kubernetes_ provider. \
Need to solve how to get the static LB external IP before create the app when using non GCP dns.
