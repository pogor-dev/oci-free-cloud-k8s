variable "tenancy_id" {
  type        = string
  description = "The tenancy to create the resources in"
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