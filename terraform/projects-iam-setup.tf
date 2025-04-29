module "projects_iam_setup" {
  source                     = "./projects-iam-setup"
  postfix                    = var.postfix
  projects_config            = local.projects
  seed_service_account_email = google_service_account.seed_service_account.email
}
