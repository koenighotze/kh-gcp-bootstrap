output "github_workload_identity_pool_name" {
  value = google_iam_workload_identity_pool.github_pool.name
}

output "github_workload_identity_pool_provider_id" {
  value = google_iam_workload_identity_pool_provider.github_provider.id
}

output "github_workload_identity_pool_provider_name" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}
