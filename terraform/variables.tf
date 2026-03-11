variable "region" {
  type        = string
  description = "GCP region for resource deployment"
  default     = "europe-west3"
}

variable "billing_account_id" {
  type        = string
  description = "GCP Billing Account ID (format: XXXXXX-XXXXXX-XXXXXX)"
  default     = "011CC2-3475B8-FC57E1"
  validation {
    condition     = can(regex("^[A-Z0-9]{6}-[A-Z0-9]{6}-[A-Z0-9]{6}$", var.billing_account_id))
    error_message = "Billing account ID must be in format XXXXXX-XXXXXX-XXXXXX (uppercase alphanumeric)."
  }
}

variable "postfix" {
  type        = string
  description = "Postfix appended to all project names to ensure uniqueness (e.g. 'prod', 'dev')"
  validation {
    condition     = length(var.postfix) > 0
    error_message = "postfix must not be empty."
  }
}

variable "seed_project_id" {
  type        = string
  description = "Id of the project where the seed resources will be deployed"
}

variable "seed_sa_id" {
  type        = string
  description = "Id of the service account that will be created in the seed project (e.g. my-org-seed-sa)"
  default     = "koenighotze-seed-sa"
}

variable "seed_repository_name" {
  type        = string
  description = "Name of the repository for workload identity, e.g., koenighotze/kh-gcp-seed"
  validation {
    condition     = length(var.seed_repository_name) > 0
    error_message = "seed_repository_name must not be empty."
  }
}

variable "github_username" {
  type        = string
  description = "GitHub username of the user who will be using the workload identity"
  validation {
    condition     = length(var.github_username) > 0
    error_message = "github_username must not be empty."
  }
}
