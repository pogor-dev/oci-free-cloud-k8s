output "oke_region" {
  description = "OCI region containing the OKE cluster and Bastion."
  value       = var.region
}

output "oke_cluster_id" {
  description = "OCID of the OKE cluster."
  value       = oci_containerengine_cluster.oke-cluster.id
}

output "bastion_id" {
  description = "OCID of the Bastion used to access the private OKE API."
  value       = oci_bastion_bastion.oke-bastion.id
}

output "oke_private_endpoint" {
  description = "Private OKE API endpoint in IP:port format."
  value       = oci_containerengine_cluster.oke-cluster.endpoints[0].private_endpoint
}
