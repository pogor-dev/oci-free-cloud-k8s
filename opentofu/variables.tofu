variable "env" {
  type        = string
  description = "The environment to create the resources in"
}

variable "org" {
  type        = string
  description = "The organization to create the resources in"
}

variable "project" {
  type        = string
  description = "The project to create the resources in"
}

variable "tenancy_ocid" {
  type        = string
  description = "The tenancy to create the resources in"
}

variable "user_ocid" {
  type        = string
  description = "The user to create the resources in"
}

variable "private_key_path" {
  type        = string
  description = "The private key path to create the resources in"
}

variable "fingerprint" {
  type        = string
  description = "The fingerprint to create the resources in"
}

variable "region" {
  description = "OCI region"
  type        = string

  default = "ap-sydney-1"
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "compute_node_image_ocid" {
  description = "OCID of the image to use for the compute node. Use Oracle Linux 9.x for Always Free tier. See https://docs.oracle.com/en-us/iaas/images/oke-worker-node-oracle-linux-9x/index.htm for more details."
  type        = string
  # TODO: Dynamically get the latest Oracle Linux 9.x image OCID for the region. For now, we will use a hardcoded value.
  default = "ocid1.image.oc1.ap-sydney-1.aaaaaaaauur44aztesxrdnt625ux6xguekeh3ohm4sawngprxeojmdy7kpaq"
}
