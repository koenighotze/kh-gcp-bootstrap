locals {
  common_apis = [
    "iam.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]

  # Roles granted to the seed SA in every child project.
  # Principle of least privilege: storage.admin removed (redundant with objectAdmin for object-level access).
  # iam.serviceAccountAdmin is required for creating/deleting downstream SAs.
  # resourcemanager.projectIamAdmin is required for granting roles in child projects via Terraform.
  common_roles = [
    "roles/storage.objectAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/resourcemanager.projectIamAdmin"
  ]
}
