output "seed_project_roles" {
  value = { for role in local.role_config : "${role.project}-${role.role}" => role }
}

output "google_project_iam_members" {
  value = google_project_iam_member.project_iam_member.*
}

output "googoogle_project_services" {
  value = google_project_service.additional_apis.*
}
