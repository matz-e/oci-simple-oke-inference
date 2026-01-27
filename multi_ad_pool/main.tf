terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.29.0"
    }
  }
  required_version = "~> 1.14.3"
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

resource "oci_containerengine_node_pool" "multi_ad_pool" {
  cluster_id     = var.oke_cluster_ocid
  compartment_id = var.compartment_ocid
  name           = local.multi_ad_pool_name
  node_shape     = "VM.Standard.E5.Flex"

  kubernetes_version = var.kubernetes_version

  node_config_details {
    nsg_ids = [var.nsg_ocid]

    placement_configs {
      availability_domain = data.oci_identity_availability_domain.ad.name
      subnet_id           = var.subnet_ocid
    }
    placement_configs {
      availability_domain = data.oci_identity_availability_domain.ad_alt.name
      subnet_id           = var.subnet_ocid
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
  subnet_id           = var.subnet_ocid
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
