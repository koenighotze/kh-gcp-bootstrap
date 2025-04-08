module "workload-identity" {
  source = "./workload-identity"

  seed_project_id                       = var.seed_project_id
  seed_repository_name                  = var.seed_repository_name
  seed_project_admin_service_account_id = data.google_service_account.seed_service_account.id
  github_username                       = var.github_username
}
