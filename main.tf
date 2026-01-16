data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

module "oci-hpc-oke" {
  source = "git::https://github.com/oracle-quickstart/oci-hpc-oke.git//terraform?ref=main"

  ssh_public_key = var.ssh_public_key

  # Works only with access to the root compartment
  create_policies = false

  kubernetes_version = "v1.34.1"

  # Challenge requirements
  create_bastion = false
  create_operator = false
  install_monitoring = false

  # Keep the basic GPU plugin
  disable_gpu_device_plugin = false

  compartment_ocid = var.compartment_ocid
  tenancy_ocid = var.tenancy_ocid

  region = var.region

  worker_ops_ad = data.oci_identity_availability_domain.ad.name
  worker_ops_image_custom_id = var.image_ocid

  worker_gpu_enabled = true
  worker_gpu_ad = data.oci_identity_availability_domain.ad.name
  worker_gpu_image_custom_id = var.image_ocid
  worker_gpu_pool_size = 1
}

locals {
  rendered_helm_values = templatefile("${path.module}/values.yaml.tmpl", {

    ad = data.oci_identity_availability_domain.ad.name
    compartment_ocid = var.compartment_ocid
    subnet_ocid = module.oci-hpc-oke.worker_subnet_id
  })
}

resource "local_file" "helm_values" {
  content  = local.rendered_helm_values
  filename = "${path.module}/values.yaml"
}
