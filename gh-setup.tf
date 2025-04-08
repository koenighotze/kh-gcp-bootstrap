# resource "github_actions_secret" "workload_identity_provider" {
#   repository      = var.seed_repository_name
#   secret_name     = "WORKLOAD_IDENTITY_PROVIDER"
#   encrypted_value = module.workload-identity.github_provider.id
# }

# resource "github_actions_secret" "workload_identity_pool_id" {
#   repository      = var.seed_repository_name
#   secret_name     = "WORKLOAD_IDENTITY_POOL_ID"
#   encrypted_value = module.workload-identity.github_pool.id
# }
