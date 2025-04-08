output "github_pool" {
  value = google_iam_workload_identity_pool.github_pool
}

output "github_provider" {
  value = google_iam_workload_identity_pool_provider.github_provider
}
