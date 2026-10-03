terraform {
  required_providers {
    oci = {
      source  = "opentofu/oci"
      version = ">= 9.8.0"
    }
  }
  required_version = ">= 1.12.6"
}
