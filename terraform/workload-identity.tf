module "workload_identity" {
  source          = "./workload-identity"
  github_username = var.github_username
}
