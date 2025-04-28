data "google_billing_account" "billing_account" {
  billing_account = var.billing_account_id
  open            = true
}
