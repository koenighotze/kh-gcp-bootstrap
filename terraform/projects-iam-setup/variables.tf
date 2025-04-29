variable "projects_config" {
  type = map(object({
    extra_apis  = list(string)
    extra_roles = list(string)
  }))
  default = {}
}

variable "postfix" {
  type        = string
  description = "Postfix to be added to the project name"
}

variable "seed_service_account_email" {
  type        = string
  description = "Email of the seed service account"
}
