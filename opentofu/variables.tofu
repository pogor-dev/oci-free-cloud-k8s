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

variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
}