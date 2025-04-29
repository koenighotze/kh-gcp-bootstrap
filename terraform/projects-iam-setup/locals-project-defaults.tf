locals {
  default_labels = {
    purpose = "koenighotze"
    owner   = "koenighotze"
  }

  common_apis = [
    "iam.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]

  # which common roles should the seed service account have in the child project.
  # these roles are needed to setup downstream resources.
  common_roles = [
    "roles/storage.admin",
    "roles/storage.objectAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/resourcemanager.projectIamAdmin"
  ]
}
