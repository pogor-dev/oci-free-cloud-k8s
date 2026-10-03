output "infra-compartment-ocid" {
  value       = oci_identity_compartment.infra-compartment.id
  description = "The OCID of the infra compartment"
}

output "oke_cluster_id" {
  description = "Cluster OCID for kubeconfig generation"
  value       = oci_containerengine_cluster.oke-cluster.id
}

output "oke_region" {
  value = var.region
}

output "oke_endpoints" {
  description = "Kubernetes API endpoints (public endpoint is disabled)"
  value       = oci_containerengine_cluster.oke-cluster.endpoints
}
