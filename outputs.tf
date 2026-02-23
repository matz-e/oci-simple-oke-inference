output "access_information" {
  value = {
    kubectl = module.oci-hpc-oke.access_k8s_public_endpoint
  }
}

data "oci_core_image" "oke" {
  image_id = var.oke_image_ocid
}

output "configured_images" {
  value = data.oci_core_image.oke.display_name
}

output "self_managed_instance" {
  value = var.self_managed_node ? {
    ocid       = oci_core_instance.self-managed[0].id
    cloud_init = local.manual_cloud_init
    os_image   = data.oci_core_image.oke.display_name
  } : null
}
