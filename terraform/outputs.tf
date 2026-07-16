output "cloud_run_url" {
  description = "Public Cloud Run URL (direct — no Cloudflare)"
  value       = google_cloud_run_v2_service.app.uri
}

output "data_bucket" {
  description = "GCS bucket name containing PII seed data"
  value       = google_storage_bucket.customer_data.name
}

output "service_account" {
  description = "Over-privileged service account (shown in Wiz toxic combination)"
  value       = google_service_account.app_sa.email
}

output "gke_cluster_name" {
  description = "GKE Autopilot cluster name"
  value       = google_container_cluster.app.name
}
