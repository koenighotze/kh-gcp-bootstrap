locals {
  // Define a map of default projects with their associated APIs and roles
  projects = {
    "kh-gcp-seed" = {
      extra_apis = []
      extra_roles = [
        "roles/iam.serviceAccountCreator",
        "roles/iam.serviceAccountDeleter",
      ]
    }

    "platform" = {
      // List of extra APIs to be enabled for the project
      extra_apis = [
        "artifactregistry.googleapis.com",
      ]

      // List of extra roles to be assigned to the service account for the project
      extra_roles = [
        "roles/artifactregistry.admin",
      ]
    }
  }
}
