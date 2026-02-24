variable "tenancy_ocid" {
  type = string
}

variable "compartment_ocid" {
  type = string
}

variable "subnet_ocid" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "nsg_ocid" {
  type = string
}

variable "vcn_ocid" {
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

variable "pool_names" {
  type    = list(string)
  default = ["piscine", "schwimmbad"]
}

variable "pool_workloads" {
  type    = list(string)
  default = ["cpu", "gpu"]
}
