data "github_user" "koenighotze" {
  username = var.github_username
}

#checkov:skip=CKV_GCP_118:Skip
#checkov:skip=CKV_GCP_125:Skip
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider-${random_integer.rand.result}"
  display_name                       = "GitHub Provider"
  description                        = "Provider for GitHub Actions"

  attribute_condition = <<EOT
    assertion.repository_owner_id == "${data.github_user.koenighotze.id}" && 
    assertion.ref == "refs/heads/main" &&          
    assertion.ref_type == "branch"                 
EOT

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
