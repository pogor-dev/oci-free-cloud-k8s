resource "oci_core_subnet" "vcn-public-subnet" {

  # Required
  compartment_id = oci_identity_compartment.infra-compartment.id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = "10.0.0.0/24"

  # Optional
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public-security-list.id]
  display_name      = "public-subnet-${var.org}-${var.project}-${var.env}"
}