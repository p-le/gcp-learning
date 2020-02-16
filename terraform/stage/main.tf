provider "google" {
    credentials = file(var.credentials_path)
    project     = var.project_name
    region      = var.region
}

module "ansible_awx" {
    source = "../modules/awx"
    zone    = var.zone
    os      = "debian-cloud/debian-10"
    user    = var.os_login_user
    private_key = var.private_key_path
}

module "awx_dns" {
    source  = "../modules/dns"
    domain    = var.domain
    public_ip = module.ansible_awx.public_ip
}

module "stage_scaling_message_queue" {
    source = "../modules/message_queue"
    name   = "stage-ansible-awx-scaling"
}

module "webservers" {
    source = "../modules/webserver"
    zone    = var.zone
    region  = var.region
    autoscaling_topic_id = module.stage_scaling_message_queue.autoscaling_topic_id
}
