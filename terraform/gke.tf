# GKE Autopilot cluster — same app, same SA, full code-to-cloud pipeline support
# (Cloud Run lacks container c2c propagation — WZ-121045)

resource "google_container_cluster" "app" {
  name     = local.name
  location = var.region

  enable_autopilot    = true
  deletion_protection = false

  network    = "default"
  subnetwork = "default"
}

# Workload Identity: allow the KSA to impersonate the over-privileged GCP SA
resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = google_service_account.app_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${local.name}/${local.name}]"

  depends_on = [google_container_cluster.app]
}

# CI SA needs container.developer to kubectl apply
resource "google_project_iam_member" "ci_container_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:ai-dlc-ci@${var.project_id}.iam.gserviceaccount.com"
}
