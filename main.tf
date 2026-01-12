# As of Jan 2026, Oracle Linux 9 is not yet supported.
data "oci_core_images" "system_image" {
  compartment_id = var.tenancy_ocid
  display_name = "Oracle-Linux-8.10-2025.11.20-0"
}

data "oci_core_images" "gpu_image" {
  compartment_id = var.tenancy_ocid
  display_name = "Oracle-Linux-8.10-Gen2-GPU-2025.11.20-0"
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

module "oci-hpc-oke" {
  source = "git::https://github.com/oracle-quickstart/oci-hpc-oke.git//terraform?ref=main"

  # Works only with access to the root compartment
  create_policies = false

  # Install the NVIDIA GPU operator later on
  disable_gpu_device_plugin = true

  compartment_ocid = var.compartment_ocid
  tenancy_ocid = var.tenancy_ocid

  region = var.region

  worker_ops_ad = data.oci_identity_availability_domain.ad.name
  worker_ops_image_custom_id = data.oci_core_images.system_image.images[0].id

  worker_gpu_enabled = true
  worker_gpu_ad = data.oci_identity_availability_domain.ad.name
  worker_gpu_image_custom_id = data.oci_core_images.gpu_image.images[0].id
  worker_gpu_pool_size = 1
}
