terraform {
  required_providers {
    oci = {
      source  = "opentofu/oci"
      version = ">= 9.8.0"
    }
  }
  required_version = ">= 1.12.6"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint      = var.fingerprint
  region           = var.region
}