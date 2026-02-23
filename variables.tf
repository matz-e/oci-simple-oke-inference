variable "tenancy_ocid" {
  type = string
}

variable "compartment_ocid" {
  type = string
}

variable "image_ocid" {
  type = string
}

variable "oke_image_ocid" {
  type        = string
  description = "Non-GPU image to use with customized node pools"
}

variable "region" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "v1.34.1"
}

variable "multi_ad_pool" {
  type    = bool
  default = false
}

variable "self_managed_node" {
  type    = bool
  default = false
}

variable "karpenter_pool" {
  type    = bool
  default = false
}
