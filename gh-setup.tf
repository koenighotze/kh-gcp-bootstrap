resource "github_actions_secret" "workload_identity_pool_name" {
  repository      = var.seed_repository_name
  secret_name     = "WORKLOAD_IDENTITY_POOL_NAME"
  plaintext_value = module.workload-identity.github_pool.name
}
