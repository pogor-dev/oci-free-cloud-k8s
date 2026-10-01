module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "4.0.0"

  vcn_name       = "vcn-${var.org}-${var.project}-${var.env}"
  tenancy_id     = var.tenancy_ocid
  compartment_id = oci_identity_compartment.infra-compartment.id
  region         = var.region

  create_internet_gateway = false
  create_nat_gateway      = false
  create_service_gateway  = false

  vcn_dns_label = "vcnmodule"
  vcn_cidrs     = ["10.0.0.0/16"]
}