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
  description = "Full container image URI pushed to Artifact Registry"
  type        = string
  default     = ""
}

variable "wiz_sensor_key" {
  description = "Wiz Runtime Sensor enrollment key (from Wiz portal > Deployments)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cf_zone_id" {
  description = "Cloudflare zone ID for ljarman.dev"
  type        = string
  default     = "f76aeaae0a33b35f2128e3b9281ddfc8"
}

variable "cf_account_id" {
  description = "Cloudflare account ID"
  type        = string
  default     = "22d63309e034efc56e2ff7605e344d83"
}

variable "hostname" {
  description = "Public hostname for the demo app"
  type        = string
  default     = "ai-dlc.ljarman.dev"
}

variable "wiz_asm_ips" {
  description = "Wiz Attack Surface Scanner IPs (Tenant Info > Wiz IPs in the Wiz portal). These rotate — refresh from the portal before re-applying."
  type        = list(string)
  default     = []
}

variable "home_ip" {
  description = "Your home/office IP for WAF allowlist. Pass via: terraform apply -var=\"home_ip=$(curl -s ifconfig.me)\""
  type        = string
}
