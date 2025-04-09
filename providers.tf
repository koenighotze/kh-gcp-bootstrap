provider "google" {
  region  = var.region
  project = var.seed_project_id
}

provider "github" {
  # token = var.github_token
}


