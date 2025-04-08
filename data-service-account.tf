data "google_service_account" "seed_service_account" {
  account_id = var.seed_project_admin_service_account_id
}
