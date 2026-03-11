# Terraform — GCP Bootstrap

Manages the seed project infrastructure for `kh-gcp-bootstrap`. This is not a general-purpose module — it is the root configuration applied once during bootstrapping and maintained as the source of truth for the seed project's GCP resources.

## What this configures

- **Seed service account** with billing admin rights
- **GitHub Workload Identity Federation** — passwordless OIDC auth for GitHub Actions
- **GitHub Actions secrets** — publishes provider/pool names so CI/CD workflows can authenticate
- **Child project IAM & APIs** — enables required APIs and grants the seed SA the necessary roles in each downstream project

## Directory structure

```
terraform/
├── main.tf                           # GCS backend configuration
├── providers.tf                      # google + github providers
├── versions.tf                       # Terraform and provider version constraints
├── variables.tf                      # All input variables
├── output.tf                         # Exported values (use terraform output -raw <name>)
├── data-billing-account.tf           # Looks up the billing account by ID
├── seed-service-account.tf           # Creates the seed SA and billing IAM binding
├── seed-repository-setup.tf          # Workload identity bindings + GitHub Actions secrets
├── workload-identity.tf              # Invokes workload-identity module
├── projects-iam-setup.tf             # Invokes projects-iam-setup module
├── locals-projects-configuration.tf  # Per-project API and role configuration
├── workload-identity/                # Module: GitHub OIDC Workload Identity pool + provider
└── projects-iam-setup/               # Module: per-project API enablement and IAM roles
```

## Prerequisites

| Requirement | Detail |
|-------------|--------|
| Terraform | >= 1.11.0 |
| GCP providers | `hashicorp/google` >= 6.7, < 7.0 |
| GCS state bucket | Must exist before `terraform init` (created by `../scripts/bootstrap.sh`) |
| `GITHUB_TOKEN` | Environment variable with `repo` and `admin:repo_hook` scopes |
| GCP credentials | Application Default Credentials (`gcloud auth application-default login`) |

## Input variables

| Variable | Required | Description |
|----------|----------|-------------|
| `billing_account_id` | yes | GCP Billing Account ID (`XXXXXX-XXXXXX-XXXXXX`) |
| `seed_project_id` | yes | GCP project ID of the seed project |
| `postfix` | yes | Suffix appended to all project names (e.g. `prod`, `dev`) |
| `seed_sa_id` | yes | Service account ID to create in the seed project |
| `seed_repository_name` | yes | GitHub repo for workload identity (e.g. `owner/repo`) |
| `github_username` | yes | GitHub username that owns the repository |
| `region` | no | GCP region (default: `europe-west3`) |

## Outputs

| Output | Description |
|--------|-------------|
| `seed_service_account_email` | Email of the created seed service account |
| `tf_state_bucket_name` | GCS bucket name used for Terraform state |
| `github_workload_identity_pool_name` | Full resource name of the Workload Identity Pool |
| `github_workload_identity_pool_provider_id` | Provider ID (used in GitHub Actions workflows) |
| `github_workload_identity_pool_provider_name` | Full provider resource name |

Retrieve a value with:
```bash
terraform output -raw seed_service_account_email
```

## Initialising and applying

Use the helper script, which passes the correct GCS bucket:

```bash
../scripts/tf-local-init.sh
terraform plan
terraform apply
```

Or manually:
```bash
terraform init -backend-config="bucket=<seed-project-id>-<postfix>-tf-state"
terraform plan \
  -var="billing_account_id=XXXXXX-XXXXXX-XXXXXX" \
  -var="seed_project_id=my-seed-project-prod" \
  -var="postfix=prod" \
  -var="seed_sa_id=my-seed-sa" \
  -var="seed_repository_name=owner/repo" \
  -var="github_username=owner"
```

## Adding a downstream project

Edit `locals-projects-configuration.tf` and add an entry to the `projects` local:

```hcl
"my-new-project" = {
  extra_apis  = ["run.googleapis.com"]
  extra_roles = ["roles/run.admin"]
}
```

The `projects-iam-setup` module automatically enables the listed APIs and grants the seed SA the listed roles (in addition to the common baseline roles) in the project `my-new-project-<postfix>`.

## Modules

### `workload-identity/`

Creates a GCP Workload Identity Pool and an OIDC provider pointed at `https://token.actions.githubusercontent.com`. The attribute condition restricts authentication to:
- The repository owner ID matching the GitHub user
- The `main` branch only
- Branch refs only (tags are excluded)

### `projects-iam-setup/`

Enables a common set of APIs (`iam`, `cloudbilling`, `cloudresourcemanager`) and grants the seed SA a baseline set of roles in every child project. Per-project extras are merged in from `locals-projects-configuration.tf`.

**Common roles granted in all child projects:**

| Role | Purpose |
|------|---------|
| `roles/storage.objectAdmin` | Manage Terraform state objects in GCS |
| `roles/iam.serviceAccountAdmin` | Create/delete downstream service accounts |
| `roles/serviceusage.serviceUsageAdmin` | Enable/disable APIs |
| `roles/resourcemanager.projectIamAdmin` | Grant IAM roles within child projects |

## Linting and validation

```bash
terraform fmt -check -recursive
terraform validate
tflint --init && tflint -f compact
trivy config .
checkov --quiet -d . --skip-check CKV_GIT_4,CKV_SECRET_6,CKV_GCP_125
```

Or use the top-level helper:
```bash
../scripts/check.sh
```
