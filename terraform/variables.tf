variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for Cloud Run and GCS"
  type        = string
  default     = "us-central1"
}

variable "app_image" {
  description = "Full container image URI (override default GCR path)"
  type        = string
  default     = ""
}

variable "wiz_sensor_client_id" {
  description = "Wiz Service Account Client ID for the Runtime Sensor (Settings > Access Management > Service Accounts, type=Sensor)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "wiz_sensor_client_secret" {
  description = "Wiz Service Account Client Secret for the Runtime Sensor"
  type        = string
  sensitive   = true
  default     = ""
}
