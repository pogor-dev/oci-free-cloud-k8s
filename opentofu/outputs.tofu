output "infra-compartment-ocid" {
  value       = oci_identity_compartment.infra-compartment.id
  description = "The OCID of the infra compartment"
}