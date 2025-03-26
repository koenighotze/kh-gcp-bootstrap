#!/usr/bin/env bash
# shellcheck disable=SC1091
# when a command fails, bash exits instead of continuing with the rest of the script
set -o errexit
# make the script fail, when accessing an unset variable
set -o nounset
# pipeline command is treated as failed, even if one command in the pipeline fails
set -o pipefail
# enable debug mode, by running your script as TRACE=1
if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/gcp-functions.sh"
source "$(dirname "$0")/1pw-functions.sh"
source "$(dirname "$0")/support-functions.sh"

function delete_seed_project() {
    local full_seed_project_name=$1

    echo "Deleting seed project: $full_seed_project_name"

    if ! project_exists "$full_seed_project_name"; then
        echo "Project $full_seed_project_name does not exist, skipping deletion"
        return
    fi

    echo gcloud projects delete "$full_seed_project_name" 
}

function delete_tf_state_bucket() {
    local full_seed_project_name=$1
    local region=$2
    local tf_state_bucket=$3

    echo "Deleting Terraform state bucket: $tf_state_bucket in region: $region"

    if ! bucket_exists "$tf_state_bucket" "$full_seed_project_name"; then
        echo "Bucket $tf_state_bucket does not exist in project $full_seed_project_name, skipping deletion"
        return
    fi

    gcloud storage buckets delete "gs://${tf_state_bucket}" --project "$full_seed_project_name" 
}

function delete_github_secrets() {
    local seed_repository=$1
    local full_seed_project_name=$2
    local billing_account=$3
    local postfix=$4
    local tf_state_bucket=$5

    if ! gh repo view "$seed_repository" >/dev/null 2>&1; then
        echo "Error: Repository $seed_repository does not exist. Skipping GitHub secrets deletion."
        return
    fi

    echo "Deleting GitHub secrets for $seed_repository"

    gh secret remove GCP_SEED_PROJECT_NAME -R "$seed_repository"
    gh secret remove GCP_BILLING_ACCOUNT_ID -R "$seed_repository"
    gh secret remove GCP_RESOURCE_POSTFIX -R "$seed_repository"
    gh secret remove TERRAFORM_STATE_BUCKET -R "$seed_repository"
}

function remove_secrets_from_vault() {
    local onepw_vault_name=$1
    local item_title="kh-gcp-bootstrap"

    echo "Removing secrets from 1Password vault: $onepw_vault_name"

    if ! vault_exists "$onepw_vault_name"; then
        echo "Vault $onepw_vault_name does not exist, skipping secrets removal"
        return
    fi

    archive_item_if_exists "$onepw_vault_name" "$item_title"
    echo "Secrets successfully removed from vault $onepw_vault_name"
}

function main() {
    local seed_project_name=$1
    local postfix=$2
    local region=$3
    local billing_account=$4
    local seed_repository=$5
    local onepw_vault_name=$6
    local full_seed_project_name="${seed_project_name}-${postfix}"
    local tf_state_bucket="${full_seed_project_name}-tf-state"

    echo "WARNING: This will remove everything from the baseline"
    confirm

    remove_secrets_from_vault "$onepw_vault_name"

    delete_github_secrets "$seed_repository" "$full_seed_project_name" "$billing_account" "$postfix" "$tf_state_bucket"

    delete_tf_state_bucket "$full_seed_project_name" "$region" "$tf_state_bucket"

    delete_seed_project "$full_seed_project_name"

    echo "Finished cleanup of $full_seed_project_name"
}

main "$SEED_PROJECT_NAME" "$POSTFIX" "$DEFAULT_REGION" "$BILLING_ACCOUNT" "$SEED_REPOSITORY_NAME" "$ONEPW_VAULT_NAME"
