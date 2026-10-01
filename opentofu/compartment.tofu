
resource "oci_identity_compartment" "tf-compartment" {
  compartment_id = var.root_compartment_ocid
  name           = var.infra_compartment_name
  description    = "Compartment for Terraform resources."
}