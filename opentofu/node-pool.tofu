# Source from https://search.opentofu.org/provider/opentofu/oci/latest/docs/resources/containerengine_node_pool

resource "oci_containerengine_node_pool" "oke-node-pool" {
  # Required
  cluster_id         = oci_containerengine_cluster.oke-cluster.id
  compartment_id     = oci_identity_compartment.infra-compartment.id
  kubernetes_version = "v1.36.4"
  name               = "oke-node-pool-${var.org}-${var.project}-${var.env}"
  node_config_details {
    node_pool_pod_network_option_details {
      cni_type          = "OCI_VCN_IP_NATIVE"
      max_pods_per_node = 31
      pod_subnet_ids    = [oci_core_subnet.vcn-node-subnet.id]
    }

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.tenancy.availability_domains[0].name
      subnet_id           = oci_core_subnet.vcn-node-subnet.id
    }
    size = 2 # For the free tier, the maximum number of worker nodes is 2. See https://www.oracle.com/cloud/free/ for more information.
  }
  node_shape = "VM.Standard.A1.Flex" # For the free tier, use VM.Standard.A1.Flex. See https://www.oracle.com/cloud/free/ for more information.

  node_shape_config {
    memory_in_gbs = 6 # For the free tier, in case of 2 worker nodes, the maximum memory is 6 GB each. See https://www.oracle.com/cloud/free/ for more information.
    ocpus         = 1 # For the free tier, in case of 2 worker nodes, the maximum OCPUs is 1 each. See https://www.oracle.com/cloud/free/ for more information.
  }

  # Using image Oracle-Linux-7.x-<date>
  # Find image OCID for your region from https://docs.oracle.com/iaas/images/ 
  node_source_details {
    image_id                = var.compute_node_image_ocid
    source_type             = "image"
    boot_volume_size_in_gbs = 100 # For the free tier, the maximum boot volume size is up to 200 GB total. See https://www.oracle.com/cloud/free/ for more information.
  }

  # Optional
  initial_node_labels {
    key   = "name"
    value = "oke-cluster-${var.org}-${var.project}-${var.env}"
  }
}
