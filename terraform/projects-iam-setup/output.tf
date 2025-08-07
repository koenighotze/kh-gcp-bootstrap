output "seed_project_roles" {
  value = { for role in local.role_config : "${role.project}-${role.role}" => role }
}

output "google_project_iam_members" {
  value = values(google_project_iam_member.project_iam_member)
}

output "google_project_services" {
  value = values(google_project_service.additional_apis)
}
