variable "tenancy_ocid" {
  type = string
}

variable "compartment_ocid" {
  type = string
}

variable "subnet_ocid" {
  type = string
}

variable "nsg_ocid" {
  type = string
}

variable "oke_cluster_ocid" {
  type = string
}

variable "oke_image_ocid" {
  type        = string
  description = "Non-GPU image to use with customized node pools"
}

variable "kubernetes_version" {
  type    = string
  default = "v1.34.1"
}

variable "fss_volume_handle" {
  type = string
}
