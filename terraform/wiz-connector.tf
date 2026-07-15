module "wiz" {
  source                           = "https://wizio-public.s3.amazonaws.com/deployment-v3/gcp/terraform/2641/wiz-gcp-project-terraform-module.zip"
  project_id                       = var.project_id
  wiz_managed_identity_external_id = "wizfe70947d83370744c817c10f340@prod-us36.iam.gserviceaccount.com"
  serverless_scanning              = true
  data_scanning                    = true
  enable_shadow_data               = true
  forensic                         = true
}
