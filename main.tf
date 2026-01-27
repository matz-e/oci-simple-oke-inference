terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.29.0"
    }
  }
  required_version = "~> 1.14.3"
}

provider "oci" {
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

module "oci-hpc-oke" {
  source = "git::https://github.com/oracle-quickstart/oci-hpc-oke.git//terraform?ref=main"

  ssh_public_key = var.ssh_public_key

  # Works only with access to the root compartment
  create_policies = false

  kubernetes_version = var.kubernetes_version

  # Challenge requirements
  create_bastion     = false
  create_operator    = false
  install_monitoring = false

  # Keep the basic GPU plugin
  disable_gpu_device_plugin = false

  compartment_ocid = var.compartment_ocid
  tenancy_ocid     = var.tenancy_ocid

  region = var.region

  worker_ops_ad              = data.oci_identity_availability_domain.ad.name
  worker_ops_image_custom_id = var.image_ocid

  worker_gpu_enabled         = true
  worker_gpu_ad              = data.oci_identity_availability_domain.ad.name
  worker_gpu_image_custom_id = var.image_ocid
  worker_gpu_pool_size       = 0
}

module "multi_ad_pool" {
  source = "./multi_ad_pool"

  count = var.multi_ad_pool ? 1 : 0

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  subnet_ocid      = module.oci-hpc-oke.worker_subnet_id
  subnet_cidr      = module.oci-hpc-oke.worker_subnet_cidr
  nsg_ocid         = module.oci-hpc-oke.worker_nsg_id
  vcn_ocid         = module.oci-hpc-oke.vcn_id

  oke_cluster_ocid = module.oci-hpc-oke.cluster_id
  oke_image_ocid   = var.oke_image_ocid

  kubernetes_version = var.kubernetes_version
}

