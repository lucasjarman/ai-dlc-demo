# Service account for the Cloud Run app
resource "google_service_account" "app_sa" {
  account_id   = "ai-dlc-demo-sa"
  display_name = "InsightHub Demo App"
  description  = "Service account for the InsightHub Cloud Run service"
}

# SECURITY ISSUE: Storage Object Admin scoped at project level, not bucket level.
# Minimal permission would be roles/storage.objectViewer on the specific bucket.
resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}

# SECURITY ISSUE: Editor role gives broad write access across all GCP services,
# enabling lateral movement to other project resources from a compromised Cloud Run instance.
resource "google_project_iam_member" "editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}
