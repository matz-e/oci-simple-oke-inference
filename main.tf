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

locals {
  multi_ad_pool_name = "piscine"
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

data "oci_identity_availability_domain" "ad_alt" {
  compartment_id = var.tenancy_ocid
  ad_number      = 2
}

module "oci-hpc-oke" {
  source = "git::https://github.com/oracle-quickstart/oci-hpc-oke.git//terraform?ref=main"

  ssh_public_key = var.ssh_public_key

  # Works only with access to the root compartment
  create_policies = false

  kubernetes_version = "v1.34.1"

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

# resource "oci_core_network_security_group_security_rule" "a" {
#   network_security_group_id = module.oci-hpc-oke.worker_nsg_id
#   protocol                  = "tcp"
#   direction = 
# }

resource "oci_containerengine_node_pool" "multi_ad_pool" {
  cluster_id     = module.oci-hpc-oke.cluster_id
  compartment_id = var.compartment_ocid
  name           = local.multi_ad_pool_name
  node_shape     = "VM.Standard.E5.Flex"

  kubernetes_version = "v1.34.1"

  node_config_details {
    nsg_ids = [module.oci-hpc-oke.worker_nsg_id]

    placement_configs {
      availability_domain = data.oci_identity_availability_domain.ad.name
      subnet_id           = module.oci-hpc-oke.worker_subnet_id
    }
    placement_configs {
      availability_domain = data.oci_identity_availability_domain.ad_alt.name
      subnet_id           = module.oci-hpc-oke.worker_subnet_id
    }

    size = 2
  }

  initial_node_labels {
    key   = "oke.oraclecloud.com/pool.name"
    value = local.multi_ad_pool_name
  }

  node_source_details {
    image_id                = var.oke_image_ocid
    source_type             = "IMAGE"
    boot_volume_size_in_gbs = 100
  }

  node_shape_config {
    memory_in_gbs = 32
    ocpus         = 8
  }
}

resource "oci_file_storage_file_system" "file_system" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid

  display_name = "File System for OKE"
}

resource "oci_file_storage_mount_target" "mount_target" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  subnet_id           = module.oci-hpc-oke.worker_subnet_id
  nsg_ids             = [oci_core_network_security_group.fss_nsg.id]

  display_name = "Mount Target for OKE"
}

resource "oci_file_storage_export" "file_export" {
  export_set_id  = oci_file_storage_mount_target.mount_target.export_set_id
  file_system_id = oci_file_storage_file_system.file_system.id
  path           = "/fss"
}

data "oci_core_private_ip" "mount_ip" {
  private_ip_id = oci_file_storage_mount_target.mount_target.private_ip_ids[0]
}
