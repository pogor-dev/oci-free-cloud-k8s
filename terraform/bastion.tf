# https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengsettingupbastion.htm
resource "oci_bastion_bastion" "oke-bastion" {
  bastion_type                 = "STANDARD"
  compartment_id               = oci_identity_compartment.infra-compartment.id
  target_subnet_id             = oci_core_subnet.vcn-bastion-subnet.id
  client_cidr_block_allow_list = var.bastion_client_cidrs
  name                         = "bastion${var.org}${var.project}${var.env}"
  max_session_ttl_in_seconds   = 10800
}
