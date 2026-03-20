terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.29.0"
    }
  }
  required_version = "~> 1.14.3"
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
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
