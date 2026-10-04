resource "oci_core_security_list" "public-security-list" {
  compartment_id = oci_identity_compartment.infra-compartment.id
  vcn_id         = module.vcn.vcn_id
  display_name   = "public-security-list-${var.org}-${var.project}-${var.env}"

  # OKE reference load-balancer security list has no ingress or egress rules.
}
