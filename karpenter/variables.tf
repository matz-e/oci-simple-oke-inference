variable "compartment_ocid" {
  type = string
}

variable "endpoint_ip" {
  type = string
  validation {
    condition = can(regex(
      "^(?:(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$",
      var.endpoint_ip
    ))
    error_message = "'endpoint_ip' needs to be a valid IPv4"
  }
}

variable "nsg_ocid" {
  type = string
}

variable "oke_image_ocid" {
  type        = string
  description = "Non-GPU image to use with customized node pools"
}

variable "region_code" {
  type = string
  validation {
    condition     = can(regex("^[A-Z]{3}$", var.region_code))
    error_message = "'region_code' needs to be a three-letter code like FRA"
  }
}

variable "subnet_ocid" {
  type = string
}
