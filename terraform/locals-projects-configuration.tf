locals {
  projects = {
    "kh-gcp-seed" = {
      extra_apis = []
      extra_roles = [
        "roles/iam.serviceAccountCreator",
        "roles/iam.serviceAccountDeleter",
      ]
    }

    "platform" = {
      extra_apis = [
        "artifactregistry.googleapis.com",
      ]

      extra_roles = [
        "roles/artifactregistry.admin",
      ]
    }

    "go-playground" = {
      extra_apis = [
      ]

      extra_roles = [
      ]
    }
  }
}
