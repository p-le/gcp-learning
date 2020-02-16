resource "google_compute_address" "stage_ansible_awx_static" {
    name = "stage-ansible-awx-address"
}

resource "google_compute_instance" "stage_ansible_awx" {
    name         = "stage-ansible-awx"
    machine_type = "g1-small"
    zone         = var.zone

    tags = [
        "http-server",
        "https-server"
    ]

    boot_disk {
        initialize_params{
            image = var.os
        }
    }

    network_interface {
        network = "default"
        access_config {
            nat_ip = google_compute_address.stage_ansible_awx_static.address
        }
    }

    provisioner "remote-exec" {
        connection {
            type        = "ssh"
            user        = var.user
            timeout     = "500s"
            host        = google_compute_address.stage_ansible_awx_static.address
            private_key = file(var.private_key)
        }

        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y git software-properties-common apt-transport-https ca-certificates curl gnupg2",
            "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -",
            "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable'",
            "apt-cache policy docker-ce",
            "echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu bionic main' | sudo tee /etc/apt/sources.list.d/ansible.list",
            "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367",
            "sudo apt-get update",
            "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1",
            "sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 2",
            "sudo update-alternatives --set python /usr/bin/python3.7",
            "sudo apt-get install -y python3-pip docker-ce nodejs npm make ansible",
            "sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1",
            "sudo -H pip install docker docker-compose",
            "sudo git clone https://github.com/ansible/awx.git /srv/ansible-awx",
            "cd /srv/ansible-awx/installer && sudo ansible-playbook -i inventory install.yml"
        ]
    }
}
