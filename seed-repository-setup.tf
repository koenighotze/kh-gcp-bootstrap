locals {
  roles = [
    "roles/iam.workloadIdentityUser",
    "roles/iam.serviceAccountTokenCreator"
  ]
}

# checkov:skip=CKV_GIT_4:Not a real secret
# checkov:skip=CKV_SECRET_6:Not a real secret
resource "github_actions_secret" "workload_identity_pool_name" {
  repository      = var.seed_repository_name
  secret_name     = "WORKLOAD_IDENTITY_PROVIDER_NAME"
  plaintext_value = google_iam_workload_identity_pool_provider.github_provider.name
}

resource "google_service_account_iam_binding" "workload_identity_bindings" {
  for_each           = toset(local.roles)
  service_account_id = data.google_service_account.seed_service_account.id
  role               = each.value
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_username}/${var.seed_repository_name}"
  ]
}
