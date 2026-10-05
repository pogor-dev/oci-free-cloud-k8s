resource "oci_core_volume" "database-volume" {
  # Required
  compartment_id      = oci_identity_compartment.infra-compartment.id
  availability_domain = data.oci_identity_availability_domains.tenancy.availability_domains[0].name

  # Optional
  display_name = "database-volume-${var.org}-${var.project}-${var.env}"
  size_in_gbs  = 50
  vpus_per_gb  = 10 # Balanced performance

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_core_volume" "shared-files-volume" {
  # Required
  compartment_id      = oci_identity_compartment.infra-compartment.id
  availability_domain = data.oci_identity_availability_domains.tenancy.availability_domains[0].name

  # Optional
  display_name = "shared-files-volume-${var.org}-${var.project}-${var.env}"
  size_in_gbs  = 50
  vpus_per_gb  = 10 # Balanced performance

  lifecycle {
    prevent_destroy = true
  }
}
