locals {
  name = "ai-dlc-demo"
  image = var.app_image != "" ? var.app_image : "${var.region}-docker.pkg.dev/${var.project_id}/${local.name}/app:latest"
}

# Artifact Registry repository for the app image
resource "google_artifact_registry_repository" "app" {
  repository_id = local.name
  format        = "DOCKER"
  location      = var.region
  description   = "InsightHub demo app images"
}

# Cloud Run service — intentionally public (no auth) for the demo
resource "google_cloud_run_v2_service" "app" {
  name     = local.name
  location = var.region

  deletion_protection = false

  template {
    service_account = google_service_account.app_sa.email

    # cpu-throttling off keeps the sensor process alive between requests
    # (avoids the 10-min activation delay on default request-based billing)
    scaling {
      min_instance_count = 1
    }

    containers {
      image = local.image

      ports {
        container_port = 8080
      }

      env {
        name  = "DATA_BUCKET"
        value = google_storage_bucket.customer_data.name
      }

      dynamic "env" {
        for_each = var.wiz_sensor_client_id != "" ? [1] : []
        content {
          name  = "WIZ_API_CLIENT_ID"
          value = var.wiz_sensor_client_id
        }
      }

      dynamic "env" {
        for_each = var.wiz_sensor_client_secret != "" ? [1] : []
        content {
          name  = "WIZ_API_CLIENT_SECRET"
          value = var.wiz_sensor_client_secret
        }
      }

      # --no-cpu-throttling ensures the sensor stays active between requests
      # (avoids 10-min activation delay with default request-based billing)
      dynamic "env" {
        for_each = var.wiz_sensor_client_id != "" ? [1] : []
        content {
          name  = "WIZ_NO_CPU_THROTTLING"
          value = "true"
        }
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
  }

  depends_on = [google_artifact_registry_repository.app]
}

# SECURITY ISSUE: allUsers invoker — publicly accessible, no authentication required
resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  name     = google_cloud_run_v2_service.app.name
  location = google_cloud_run_v2_service.app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
