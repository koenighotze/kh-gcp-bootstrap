output "github_workload_identity_pool_name" {
  value = module.workload_identity.github_workload_identity_pool_name
}

output "github_workload_identity_pool_provider_id" {
  value = module.workload_identity.github_workload_identity_pool_provider_id
}

output "github_workload_identity_pool_provider_name" {
  value = module.workload_identity.github_workload_identity_pool_provider_name
}

output "seed_service_account_email" {
  value = google_service_account.seed_service_account.email
}

output "tf_state_bucket_name" {
  value       = "${var.seed_project_id}-${var.postfix}-tf-state"
  description = "GCS bucket used for Terraform state"
}
