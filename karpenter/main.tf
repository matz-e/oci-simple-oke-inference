locals {
  rendered_karpenter_values = templatefile("${path.module}/karpenter_values.yaml.tmpl", {
    compartment_ocid = var.compartment_ocid
    region_code      = var.region_code
    replicas         = 1
    endpoint_ip      = var.endpoint_ip
  })

  rendered_karpenter_resources = templatefile("${path.module}/karpenter_resources.yaml.tmpl", {
    image_ocid  = var.oke_image_ocid
    subnet_ocid = var.subnet_ocid
    nsg_ocid    = var.nsg_ocid
  })
}

resource "local_file" "karpenter_values_yaml" {
  content         = local.rendered_karpenter_values
  filename        = "${path.module}/karpenter_values.yaml"
  file_permission = "0666"
}

resource "local_file" "karpenter_resources_yaml" {
  content         = local.rendered_karpenter_resources
  filename        = "${path.module}/karpenter_resources.yaml"
  file_permission = "0666"
}
