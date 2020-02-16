output "private_ip" {
    value = google_compute_instance.stage_ansible_awx.network_interface[0].network_ip
}

output "public_ip" {
    value = google_compute_instance.stage_ansible_awx.network_interface[0].access_config[0].nat_ip
}
