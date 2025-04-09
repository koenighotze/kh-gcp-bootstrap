output "github_workload_identity_pool_name" {
  value = module.workload-identity.github_pool.name
}

output "github_workload_identity_pool_provider_id" {
  value = module.workload-identity.github_provider.id
}

output "github_workload_identity_pool_provider_name" {
  value = module.workload-identity.github_provider.name
}
