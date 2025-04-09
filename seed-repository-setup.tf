resource "github_actions_secret" "workload_identity_pool_name" {
  repository      = var.seed_repository_name
  secret_name     = "WORKLOAD_IDENTITY_POOL_NAME"
  plaintext_value = google_iam_workload_identity_pool.github_pool.name
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = data.google_service_account.seed_service_account.id
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.seed_repository_name}"
  ]
}

