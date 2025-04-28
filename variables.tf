variable "region" {
  type    = string
  default = "europe-west3"
}

variable "billing_account_id" {
  type        = string
  description = "Billing account id"
  default     = "011CC2-3475B8-FC57E1"
}

variable "seed_project_id" {
  type        = string
  description = "Id of the project where the seed resources will be deployed"
}

variable "seed_sa_id" {
  type        = string
  description = "Id of the service account that will be created in the seed project"
  default     = "koenighotze-seed-sa"
}

variable "seed_repository_name" {
  type        = string
  description = "Name of the repository for workload identity, e.g., koenighotze/kh-gcp-seed"
}

variable "seed_project_admin_service_account_id" {
  type    = string
  default = "Id of the seed project's admin service account"
}

variable "github_username" {
  type        = string
  description = "GitHub username of the user who will be using the workload identity"
}
