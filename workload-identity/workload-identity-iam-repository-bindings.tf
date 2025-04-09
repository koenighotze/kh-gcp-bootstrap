resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = var.seed_project_admin_service_account_id
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.seed_repository_name}"
  ]
}

