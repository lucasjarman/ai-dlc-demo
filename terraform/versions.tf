terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "cloudflare" {
  # CLOUDFLARE_API_TOKEN env var — fetch from BWS before running terraform
  # export CLOUDFLARE_API_TOKEN="$(bws --color no secret get e460fedc-b741-4aa0-b8c4-b485004684b7 -o json | jq -r .value)"
}
