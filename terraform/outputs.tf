output "cloud_run_url" {
  description = "Direct Cloud Run URL (internal — not for sharing)"
  value       = google_cloud_run_v2_service.app.uri
}

output "public_url" {
  description = "Public demo URL via Cloudflare"
  value       = "https://${var.hostname}"
}

output "data_bucket" {
  description = "GCS bucket name containing PII seed data"
  value       = google_storage_bucket.customer_data.name
}

output "service_account" {
  description = "Over-privileged service account email (shown in Wiz toxic combination)"
  value       = google_service_account.app_sa.email
}

output "artifact_registry" {
  description = "Artifact Registry repo for docker push"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app.repository_id}"
}
