locals {
  role_config = flatten([for project, config in var.projects_config : [for role in concat(local.common_roles, config.extra_roles) : { project = "${project}-${var.postfix}", role = role }]])
  api_config  = flatten([for project, config in var.projects_config : [for api in concat(local.common_apis, config.extra_apis) : { project = "${project}-${var.postfix}", api = api }]])
}

resource "google_project_service" "additional_apis" {
  for_each = { for api in local.api_config : "${api.project}-${api.api}" => api }

  project = each.value.project
  service = each.value.api
}

resource "google_project_iam_member" "project_iam_member" {
  for_each = { for role in local.role_config : "${role.project}-${role.role}" => role }

  project = each.value.project
  role    = each.value.role
  member  = "serviceAccount:${var.seed_service_account_email}" # Changed to use a variable
}
