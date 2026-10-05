data "oci_identity_availability_domains" "tenancy" {
  compartment_id = oci_identity_compartment.infra-compartment.id
}
