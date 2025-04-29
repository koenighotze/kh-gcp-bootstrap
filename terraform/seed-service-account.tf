resource "google_service_account" "seed_service_account" {
  project      = var.seed_project_id
  account_id   = var.seed_sa_id
  display_name = "Seed account for Koenighotze"
}

resource "google_billing_account_iam_member" "seed_sa_billing_role" {
  billing_account_id = data.google_billing_account.billing_account.id
  role               = "roles/billing.admin"
  member             = "serviceAccount:${google_service_account.seed_service_account.email}"
}

resource "github_actions_secret" "seed_sa_email" {
  repository      = var.seed_repository_name
  secret_name     = "SEED_SA_EMAIL_ADDRESS"
  plaintext_value = google_service_account.seed_service_account.email
}

