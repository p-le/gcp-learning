resource "google_dns_record_set" "default" {
    name = "awx.${google_dns_managed_zone.default.dns_name}"
    type = "A"
    ttl  = 300

    managed_zone = google_dns_managed_zone.default.name
    rrdatas = [
        var.public_ip
    ]
}

resource "google_dns_managed_zone" "default" {
    name     = "stage-zone"
    dns_name = "${var.domain}."
}
