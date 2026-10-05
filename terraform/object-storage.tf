resource "oci_objectstorage_bucket" "tofu_backend_bucket" {
  # Required
  compartment_id = oci_identity_compartment.infra-compartment.id
  name           = "object-storage-${var.org}-${var.project}-${var.env}"
  namespace      = var.object_storage_namespace

  # Optional
  access_type  = "NoPublicAccess"
  auto_tiering = "Disabled"
  versioning   = "Enabled"

  lifecycle {
    prevent_destroy = true
  }
}
