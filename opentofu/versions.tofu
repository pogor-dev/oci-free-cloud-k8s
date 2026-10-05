terraform {
  required_providers {
    oci = {
      source  = "opentofu/oci"
      version = ">= 9.8.0"
    }
  }
  # backend "oci" {
  #   # Required
  #   bucket    = "mybucket"
  #   namespace = var.object_storage_namespace

  #   # Optional
  #   tenancy_ocid         = var.tenancy_ocid
  #   user_ocid            = var.user_ocid
  #   fingerprint          = var.fingerprint
  #   private_key_path     = var.private_key_path
  #   region               = var.region
  #   workspace_key_prefix = "envs/"
  #   kms_key_id           = "ocid1.key.oc1.iad.xxxxxxxxxxxxxx"
  #   auth                 = "APIKey"
  #   config_file_profile  = "DEFAULT"
  # }
  required_version = ">= 1.12.6"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint      = var.fingerprint
  region           = var.region
}