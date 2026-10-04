locals {
  private_subnet_cidr = "10.0.10.0/24"
  api_subnet_cidr     = "10.0.0.0/28"
}

resource "oci_core_subnet" "vcn-private-subnet" {

  # Required
  compartment_id = oci_identity_compartment.infra-compartment.id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = local.private_subnet_cidr

  prohibit_public_ip_on_vnic = true

  # Optional
  dns_label = "workers"
  # Caution: For the route table id, use module.vcn.nat_route_id.
  # Do not use module.vcn.nat_gateway_id, because it is the OCID for the gateway and not the route table.
  route_table_id    = module.vcn.nat_route_id
  security_list_ids = [oci_core_security_list.private-security-list.id]
  display_name      = "node-subnet-${var.org}-${var.project}-${var.env}"
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
  display_name      = "k8s-api-endpoint-subnet-${var.org}-${var.project}-${var.env}"
}

resource "oci_core_subnet" "vcn-public-subnet" {

  # Required
  compartment_id = oci_identity_compartment.infra-compartment.id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = "10.0.20.0/24"

  prohibit_public_ip_on_vnic = false

  # Optional
  dns_label         = "loadbalancers"
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public-security-list.id]
  display_name      = "svc-lb-subnet-${var.org}-${var.project}-${var.env}"
}
