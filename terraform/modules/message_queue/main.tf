resource "google_pubsub_topic" "default" {
    name = "${var.name}-topic"
}

resource "google_pubsub_subscription" "pull_default" {
    name  = "${var.name}-pull-sub"
    topic = google_pubsub_topic.default.name

    message_retention_duration = "1200s"
    retain_acked_messages      = true
    ack_deadline_seconds = 20

    expiration_policy {
        ttl = "300000.5s"
    }
}

resource "google_pubsub_subscription" "push_default" {
    name  = "${var.name}-push-sub"
    topic = google_pubsub_topic.default.name

    ack_deadline_seconds = 20

    push_config {
        push_endpoint = "https://example.com/push"

        attributes = {
            x-goog-version = "v1"
        }
    }
}
