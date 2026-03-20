output "fss_volume_handle" {
  value = "${oci_file_storage_mount_target.mount_target.id}:${data.oci_core_private_ip.mount_ip.ip_address}:${oci_file_storage_export.file_export.path}"
}
