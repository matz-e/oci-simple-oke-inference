locals {
  rendered_helm_values = templatefile("${path.module}/values.yaml.tmpl", {

    ad               = data.oci_identity_availability_domain.ad.name
    compartment_ocid = var.compartment_ocid
    subnet_ocid      = module.oci-hpc-oke.worker_subnet_id
  })

  rendered_bv_storage_values = templatefile("${path.module}/storage-bv.yaml.tmpl", {
    pool_name = oci_containerengine_node_pool.multi_ad_pool.name
  })

  rendered_fss_storage_values = templatefile("${path.module}/storage-fss.yaml.tmpl", {
    fss_ocid  = oci_file_storage_mount_target.mount_target.id
    fss_path  = oci_file_storage_export.file_export.path
    fss_ip    = data.oci_core_private_ip.mount_ip.ip_address
    pool_name = oci_containerengine_node_pool.multi_ad_pool.name
  })
}

resource "local_file" "helm_values" {
  content         = local.rendered_helm_values
  filename        = "${path.module}/values.yaml"
  file_permission = "0666"
}

resource "local_file" "storage_bv_deployment" {
  content         = local.rendered_bv_storage_values
  filename        = "${path.module}/storage-bv.yaml"
  file_permission = "0666"
}

resource "local_file" "storage_fss_deployment" {
  content         = local.rendered_fss_storage_values
  filename        = "${path.module}/storage-fss.yaml"
  file_permission = "0666"
}
