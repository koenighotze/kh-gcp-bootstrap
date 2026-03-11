# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`kh-gcp-bootstrap` bootstraps GCP infrastructure: creates a seed project, seed service account, Terraform state bucket, GitHub Workload Identity integration, and downstream projects. The workflow is scripted orchestration (Bash) + Terraform for ongoing IaC.

## Common Commands

### Linting & Validation

```bash
# Terraform checks (TFLint, validate, fmt, Trivy, Checkov)
./scripts/check.sh

# Shell script checks (shellcheck, shfmt, beautysh)
./scripts/clean-sh.sh
```

Individual checks:

```bash
tflint --init && tflint -f compact          # Terraform lint
terraform validate -no-color               # Terraform validate
terraform fmt -check -recursive            # Format check
trivy config .                             # Security scan
checkov --quiet -d . --skip-check CKV_GCP_125  # Compliance scan
shellcheck scripts/*                       # Shell lint
```

### Bootstrap Workflow (initial setup)

```bash
./scripts/bootstrap.sh        # Create seed project, state bucket, GitHub secrets, 1Password vault
./scripts/create-projects.sh  # Create downstream GCP projects
./scripts/tf-local-init.sh    # Initialize Terraform with GCS backend
terraform plan
terraform apply -auto-approve
```

### Teardown

```bash
./scripts/delete-projects.sh    # Delete downstream projects
./scripts/delete-bootstrap.sh   # Delete seed project, state bucket, GitHub secrets
```

## Architecture

### Configuration Hub: `scripts/common.sh`

All shared variables are defined here: `POSTFIX`, `BILLING_ACCOUNT`, `DEFAULT_REGION`, project names, SA email, 1Password vault name. `scripts/local.sh` (gitignored) provides local overrides and is sourced automatically.

`scripts/projects.sh` defines the `PROJECTS` array (currently `["platform", "go-playground"]`).

### Terraform Modules

- **Root** (`terraform/`): Manages seed project infrastructure; uses GCS backend (`${full_seed_project_name}-tf-state`).
- **`workload-identity/`**: GitHub Actions OIDC integration via Workload Identity Federation. Restricts to specific repo owner, `main` branch, branch ref type.
- **`projects-iam-setup/`**: Configures IAM roles and API enablement per project. Project-specific config lives in `terraform/locals-projects-configuration.tf`.

### Key Patterns

- **Idempotency**: All `create-*` scripts check existence before creating (via functions in `scripts/gcp-functions.sh`).
- **No SA key files**: Authentication uses Workload Identity Federation (passwordless).
- **Debug mode**: Set `TRACE=1` to enable `set -o xtrace` in any script.
- **Strict bash**: All scripts use `set -o errexit -o nounset -o pipefail`.
- **1Password integration**: Secrets stored in `kh-development` vault via `scripts/1pw-functions.sh`.

### CI/CD (GitHub Actions)

- `.github/workflows/qa-scripts.yml`: ShellCheck on all scripts (excludes SC1091).
- `.github/workflows/qa-terraform.yml`: Parallel jobs for Trivy security scan, Checkov compliance, TFLint. Skips: `CKV_GIT_4`, `CKV_SECRET_6`, `CKV_GCP_125`.
