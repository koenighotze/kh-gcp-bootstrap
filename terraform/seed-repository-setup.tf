resource "github_actions_secret" "workload_identity_pool_name" {
  repository      = var.seed_repository_name
  secret_name     = "WORKLOAD_IDENTITY_PROVIDER_NAME"
  plaintext_value = module.workload_identity.github_workload_identity_pool_provider_name
}

resource "google_service_account_iam_binding" "workload_identity_bindings" {
  for_each = toset([
    "roles/iam.workloadIdentityUser",
    "roles/iam.serviceAccountTokenCreator"
  ])
  service_account_id = google_service_account.seed_service_account.id
  role               = each.value
  members = [
    "principalSet://iam.googleapis.com/${module.workload_identity.github_workload_identity_pool_name}/attribute.repository/${var.github_username}/${var.seed_repository_name}"
  ]
}
