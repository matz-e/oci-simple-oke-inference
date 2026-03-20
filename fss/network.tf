resource "oci_core_network_security_group" "fss_nsg" {
  compartment_id = var.compartment_ocid
  display_name   = "FSS NSG"
  vcn_id         = var.vcn_ocid
}

locals {
  mount_target_cidr = "${data.oci_core_private_ip.mount_ip.ip_address}/32"
}

resource "oci_core_network_security_group_security_rule" "ingress_tcp_multiports" {
  count                     = 2
  network_security_group_id = oci_core_network_security_group.fss_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = var.subnet_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = [111, 2048][count.index]
      max = [111, 2050][count.index]
    }
  }
  stateless = false
}

resource "oci_core_network_security_group_security_rule" "ingress_udp" {
  count                     = 2
  network_security_group_id = oci_core_network_security_group.fss_nsg.id
  direction                 = "INGRESS"
  protocol                  = "17" # UDP
  source                    = var.subnet_cidr
  source_type               = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      min = [111, 2048][count.index]
      max = [111, 2050][count.index]
    }
  }
  stateless = false
}

resource "oci_core_network_security_group_security_rule" "egress_tcp" {
  count                     = 2
  network_security_group_id = oci_core_network_security_group.fss_nsg.id
  direction                 = "EGRESS"
  protocol                  = "6" # TCP
  destination               = local.mount_target_cidr
  destination_type          = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = [111, 2048][count.index]
      max = [111, 2050][count.index]
    }
  }
  stateless = false
}

resource "oci_core_network_security_group_security_rule" "egress_udp" {
  count                     = 2
  network_security_group_id = oci_core_network_security_group.fss_nsg.id
  direction                 = "EGRESS"
  protocol                  = "17" # UDP
  destination               = local.mount_target_cidr
  destination_type          = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      min = [111, 2048][count.index]
      max = [111, 2048][count.index]
    }
  }
  stateless = false
}
