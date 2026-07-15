# GCS bucket holding sensitive customer PII data
resource "google_storage_bucket" "customer_data" {
  name          = "${var.project_id}-customer-data"
  location      = var.region
  force_destroy = true

  # SECURITY ISSUE: uniform_bucket_level_access disabled — falls back to legacy ACLs
  # which are harder to audit and can lead to unintended public exposure.
  uniform_bucket_level_access = false

  # No CMEK — relies on Google-managed default encryption only
}

resource "google_storage_bucket_object" "customers_csv" {
  name         = "customers.csv"
  bucket       = google_storage_bucket.customer_data.name
  source       = "${path.root}/../data/customers.csv"
  content_type = "text/csv"
}

resource "google_storage_bucket_object" "employees_csv" {
  name         = "employees.csv"
  bucket       = google_storage_bucket.customer_data.name
  source       = "${path.root}/../data/employees.csv"
  content_type = "text/csv"
}
