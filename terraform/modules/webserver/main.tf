data "google_compute_image" "debian_10" {
    family  = "debian-10"
    project = "debian-cloud"
}

resource "google_compute_address" "stage_webserver_static_address" {
    name = "stage-webserver-address"
}

resource "google_compute_instance_template" "default" {
    name           = "stage-webserver-template"
    machine_type   = "n1-standard-1"
    can_ip_forward = false

    tags = [
        "http-server",
        "https-server"
    ]

    disk {
        source_image = data.google_compute_image.debian_10.self_link
    }

    labels = {
        environment = "dev"
        role = "webservice"
    }

    metadata_startup_script = "sudo apt-get install nginx-extras"

    network_interface {
        network = "default"
    }
}

resource "google_compute_autoscaler" "default" {
    name   = "stage-webserver-autoscaler"
    zone   = var.zone
    target = google_compute_instance_group_manager.default.self_link

    autoscaling_policy {
        max_replicas    = 4
        min_replicas    = 1
        cooldown_period = 60
    }
}

resource "google_compute_global_forwarding_rule" "default" {
    name       = "stage-http-global-forwarding-rule"
    target     = google_compute_target_http_proxy.default.self_link
    port_range = "80"
}

resource "google_compute_target_http_proxy" "default" {
    name        = "target-proxy"
    description = "Staging Webserver"
    url_map     = google_compute_url_map.default.self_link
}

resource "google_compute_url_map" "default" {
    name            = "url-map-target-proxy"
    description     = "a description"
    default_service = google_compute_backend_service.default.self_link

    host_rule {
        hosts        = [
            "phu-le.dev"
        ]
        path_matcher = "allpaths"
    }

    path_matcher {
        name            = "allpaths"
        default_service = google_compute_backend_service.default.self_link

        path_rule {
            paths   = ["/*"]
            service = google_compute_backend_service.default.self_link
        }
    }
}

resource "google_compute_backend_service" "default" {
    name        = "backend"
    port_name   = "http"
    protocol    = "HTTP"
    timeout_sec = 10

    backend {
        group = google_compute_instance_group_manager.default.instance_group
        description = "webserver instance groups"
    }

    health_checks = [
        google_compute_http_health_check.default.self_link
    ]
}

resource "google_compute_http_health_check" "default" {
    name               = "stage-health-check"
    request_path       = "/"
    check_interval_sec = 60
    timeout_sec        = 15
}

resource "google_compute_instance_group_manager" "default" {
    name = "stage-webserver-igm"
    zone = var.zone

    version {
        instance_template = google_compute_instance_template.default.self_link
        name              = "primary"
    }

    base_instance_name = "stage-webserver"
    lifecycle {
        create_before_destroy = true
    }
}

resource "google_logging_project_sink" "default" {
    name = "autoscaling-sink"
    destination = "pubsub.googleapis.com/${var.autoscaling_topic_id}"
    filter = "resource.type=gce_instance AND severity=NOTICE"
    unique_writer_identity = true
}

resource "google_compute_router" "default" {
    name    = "staging-webserver-router"
    region  = var.region
    network = "default"
}

resource "google_compute_router_nat" "default" {
    name   = "staging-webserver-router-nat"
    router = google_compute_router.default.name
    region = var.region

    nat_ip_allocate_option = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
