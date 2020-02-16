output "ansible_awx_private_ip" {
    value = module.ansible_awx.private_ip
}

output "ansible_awx_public_ip" {
    value = module.ansible_awx.public_ip
}
