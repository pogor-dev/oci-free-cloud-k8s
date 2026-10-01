# resource "oci_containerengine_cluster" "oke-cluster" {
#   compartment_id     = oci_identity_compartment.infra-compartment.id
#   kubernetes_version = "v1.36"
#   name               = "<your-cluster-name>"
#   vcn_id             = module.vcn.vcn_id

#   options {
#     kubernetes_network_config {
#       pods_cidr     = "10.244.0.0/16"
#       services_cidr = "10.96.0.0/16"
#     }
#     service_lb_subnet_ids = [oci_core_subnet.vcn-public-subnet.id]
#   }
# }