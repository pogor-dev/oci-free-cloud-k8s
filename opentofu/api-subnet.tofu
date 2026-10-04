locals {
  api_subnet_cidr = "10.0.0.0/28"
}

resource "oci_core_subnet" "vcn-api-subnet" {

  # Required
  compartment_id = oci_identity_compartment.infra-compartment.id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = local.api_subnet_cidr

  prohibit_public_ip_on_vnic = true

  # Optional
  dns_label         = "api"
  route_table_id    = module.vcn.nat_route_id
  security_list_ids = [oci_core_security_list.api-security-list.id]
  display_name      = "api-subnet-${var.org}-${var.project}-${var.env}"
}
