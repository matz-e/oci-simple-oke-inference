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

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

module "oci-hpc-oke" {
  source = "git::https://github.com/oracle-quickstart/oci-hpc-oke.git//terraform?ref=main"

  ssh_public_key = var.ssh_public_key

  # Works only with access to the root compartment
  create_policies = false

  kubernetes_version = var.kubernetes_version

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
  worker_ops_pool_size       = 1

  worker_gpu_enabled         = true
  worker_gpu_ad              = data.oci_identity_availability_domain.ad.name
  worker_gpu_image_custom_id = var.image_ocid
  worker_gpu_pool_size       = 0
}

resource "oci_containerengine_addon" "certificate_addon" {
  addon_name                       = "CertManager"
  cluster_id                       = module.oci-hpc-oke.cluster_id
  remove_addon_resources_on_delete = true
}

resource "oci_containerengine_addon" "metrics_addon" {
  addon_name                       = "KubernetesMetricsServer"
  cluster_id                       = module.oci-hpc-oke.cluster_id
  remove_addon_resources_on_delete = true
  depends_on                       = [oci_containerengine_addon.certificate_addon]
}

module "multi_ad_pool" {
  source = "./multi_ad_pool"

  count = var.multi_ad_pool ? 1 : 0

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  subnet_ocid      = module.oci-hpc-oke.worker_subnet_id
  subnet_cidr      = module.oci-hpc-oke.worker_subnet_cidr
  nsg_ocid         = module.oci-hpc-oke.worker_nsg_id
  vcn_ocid         = module.oci-hpc-oke.vcn_id

  oke_cluster_ocid = module.oci-hpc-oke.cluster_id
  oke_image_ocid   = var.oke_image_ocid

  kubernetes_version = var.kubernetes_version
}

locals {
  encoded_cert      = base64encode(module.oci-hpc-oke.cluster_ca_cert)
  endpoint_ip_match = regex("https://([0-9\\.]+):[0-9]+", module.oci-hpc-oke.cluster_private_endpoint)
  endpoint_ip       = local.endpoint_ip_match[0]

  manual_cloud_init = <<-EOS
  #!/usr/bin/env bash
  set -x
  bash /etc/oke/oke-install.sh \
    --apiserver-endpoint "${local.endpoint_ip}" \
    --kubelet-ca-cert "${local.encoded_cert}"
  sleep 30
  systemctl status oke.service
  cat /etc/oke/oke-install.sh
  cat /etc/oke/oke.conf
  cat /etc/kubernetes/ca.crt
  EOS
}

resource "oci_core_instance" "self-managed" {
  count = var.self_managed_node ? 1 : 0

  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  shape               = "VM.Standard.E5.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 32
  }

  create_vnic_details {
    assign_public_ip = false
    subnet_id        = module.oci-hpc-oke.worker_subnet_id
    subnet_cidr      = module.oci-hpc-oke.worker_subnet_cidr
    nsg_ids          = [module.oci-hpc-oke.worker_nsg_id]
  }

  source_details {
    source_type             = "image"
    source_id               = var.oke_image_ocid
    boot_volume_size_in_gbs = "100"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(local.manual_cloud_init)
  }
}

module "karpenter" {
  source = "./karpenter"

  count = var.karpenter_pool ? 1 : 0

  endpoint_ip = local.endpoint_ip
  region_code = local.region_code

  compartment_ocid = var.compartment_ocid
  nsg_ocid         = module.oci-hpc-oke.worker_nsg_id
  oke_image_ocid   = var.oke_image_ocid
  subnet_ocid      = module.oci-hpc-oke.worker_subnet_id
}
