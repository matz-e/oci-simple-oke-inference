locals {
  rendered_fss_storage_values = templatefile("${path.module}/storage-fss.yaml.tmpl", {
    fss_ocid  = oci_file_storage_mount_target.mount_target.id
    fss_path  = oci_file_storage_export.file_export.path
    fss_ip    = data.oci_core_private_ip.mount_ip.ip_address
  })
}

resource "local_file" "storage_fss_deployment" {
  content         = local.rendered_fss_storage_values
  filename        = "${path.module}/storage-fss.yaml"
  file_permission = "0666"
}
