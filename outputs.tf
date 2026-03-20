output "access_information" {
  value = {
    kubectl  = module.oci-hpc-oke.access_k8s_public_endpoint
    operator = var.additional_nodes ? module.oci-hpc-oke.operator_ssh_command : null
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

output "lb_info" {
  value = {
    compartment = var.compartment_ocid
    lb_subnet   = module.oci-hpc-oke.pub_lb_subnet_id
  }
}

output "fss_info" {
  value = anytrue([var.multi_ad_pool, var.additional_fss]) ? module.fss[0].fss_volume_handle : null
}
