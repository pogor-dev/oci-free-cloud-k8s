terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 9.8.0"
    }
  }
  backend "oci" {
    # Terraform backends require literal values; -var-file does not configure them.
    # Required
    bucket    = "object-storage-shared-infra-prod"
    namespace = "sdhy9ythd3tg"

    # Optional
    config_file_profile = "DEFAULT"
    region              = "ap-sydney-1"
    key                 = "terraform-state-shared-infra-prod.tfstate"
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
