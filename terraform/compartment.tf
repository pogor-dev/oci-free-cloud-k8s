
resource "oci_identity_compartment" "infra-compartment" {
  compartment_id = var.tenancy_ocid
  name           = "cmp-${var.org}-${var.project}-${var.env}"
  description    = "Compartment for Terraform resources."
}
