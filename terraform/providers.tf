provider "google" {
  region  = var.region
  project = var.seed_project_id
}

# Requires GITHUB_TOKEN environment variable with 'repo' and 'admin:repo_hook' scopes.
provider "github" {
}


