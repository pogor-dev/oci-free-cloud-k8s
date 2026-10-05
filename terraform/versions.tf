terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 9.8.0"
    }
  }
  backend "oci" {
    # Required
    bucket    = "object-storage-${var.org}-${var.project}-${var.env}"
    namespace = var.object_storage_namespace

    # Optional
    tenancy_ocid     = var.tenancy_ocid
    user_ocid        = var.user_ocid
    fingerprint      = var.fingerprint
    private_key_path = var.private_key_path
    region           = var.region
    key              = "terraform-state-${var.org}-${var.project}-${var.env}.tfstate"
  }

  required_version = ">= 1.12.0"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint      = var.fingerprint
  region           = var.region
}