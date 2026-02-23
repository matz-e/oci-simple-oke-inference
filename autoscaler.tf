data "oci_identity_regions" "all" {}

locals {
  scaler_image_tags = {
    "v1.31" = "1.31.3-2"
    "v1.32" = "1.32.5-261"
    "v1.33" = "1.33.3-253"
    "v1.34" = "1.34.2-252"
  }

  region_code = lower(one([
    for r in data.oci_identity_regions.all.regions : r.key
    if r.name == var.region
  ]))

  pool_ocid = module.oci-hpc-oke.worker_ops_pool_id

  kubernetes_major_minor = join(".", slice(split(".", var.kubernetes_version), 0, 2))

  rendered_scaler_template = templatefile("${path.module}/autoscaler.yaml.tmpl", {
    pool_ocid = local.pool_ocid
    region    = local.region_code
    image_tag = local.scaler_image_tags[local.kubernetes_major_minor]
  })
}

resource "local_file" "autoscaler_yaml" {
  content         = local.rendered_scaler_template
  filename        = "${path.module}/autoscaler.yaml"
  file_permission = "0666"
}
