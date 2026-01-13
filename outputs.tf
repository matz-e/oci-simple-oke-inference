output "bastion_ssh_command" {
  value = module.oci-hpc-oke.bastion_ssh_command
}

output "grafana_url" {
  value = module.oci-hpc-oke.grafana_url
}

output "grafana_admin_password" {
  value = module.oci-hpc-oke.grafana_admin_password
}

output "grafana_admin_username" {
  value = module.oci-hpc-oke.grafana_admin_username
}

output "access_k8s_public_endpoint" {
  value = module.oci-hpc-oke.access_k8s_public_endpoint
}
