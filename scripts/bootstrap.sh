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

function main() {
    local seed_project_name=$1
    local postfix=$2
    local region=$3
    local billing_account=$4
    local seed_repository=$5
    local onepw_vault_name=$6
    local full_seed_project_name="${seed_project_name}-${postfix}"
    local tf_state_bucket="${full_seed_project_name}-tf-state"

    create_seed_project "$full_seed_project_name"

    enable_billing "$full_seed_project_name" "$billing_account" 

    create_tf_state_bucket "$full_seed_project_name" "$region" "$tf_state_bucket"

    setup_github_secrets "$seed_repository" "$full_seed_project_name" "$billing_account" "$postfix" "$tf_state_bucket"

    create_secrets_vault "$onepw_vault_name"

    add_secrets_to_vault "$onepw_vault_name" "$seed_repository" "$full_seed_project_name" "$billing_account" "$postfix" "$tf_state_bucket"

    echo "Finished bootstrapping $full_seed_project_name"
}

function create_seed_project() {
    local project=$1

    echo "Creating seed project $project"

    if project_exists "$project"
    then
        echo "Project $project already exists, will not create"
        
        return
    fi
    
    # since Terraform cannot create projects without an organization,
    # we use gcloud cli for the time being
    gcloud projects create "$project" --name="Koenighotze Seed" --labels=purpose=seed
}

function create_tf_state_bucket() {
    local project=$1
    local region=$2
    local tf_state_bucket=$3

    echo "Creating Terraform state bucket for $project in region $region"

    if bucket_exists "$tf_state_bucket" "$project"
    then
        echo "Bucket $tf_state_bucket already exists in project $project, will not create"
        
        return
    fi

    gcloud storage buckets create "gs://${tf_state_bucket}" --project "$project" --location "$region"
}

function setup_github_secrets() {
    local seed_repository=$1
    local full_seed_project_name=$2
    local billing_account=$3
    local postfix=$4
    local tf_state_bucket=$5

    if ! gh repo view "$seed_repository" >/dev/null 2>&1; then
        echo "Error: Repository $seed_repository does not exist. Exiting."
        exit 1
    fi

    echo "Setting up GitHub secrets for $seed_repository"

    gh secret set GCP_SEED_PROJECT_NAME -R "$seed_repository" -b "$full_seed_project_name"
    gh secret set GCP_BILLING_ACCOUNT_ID -R "$seed_repository" -b "$billing_account"
    gh secret set GCP_RESOURCE_POSTFIX -R "$seed_repository" -b "$postfix"
    gh secret set TERRAFORM_STATE_BUCKET -R "$seed_repository" -b "$tf_state_bucket"
}

function enable_billing() {
    local project=$1
    local billingAccount=$2

    echo "Enabling billing for $project with billing account $billingAccount"

    gcloud beta billing projects link "$project" --billing-account "$billingAccount"
}

function create_secrets_vault() {
    local vault_name=$1

    if vault_exists "$vault_name"
    then
        echo "Vault $vault_name already exists, will not create"
        return 0
    fi

    echo "Creating 1Password vault $vault_name"
    op vault create "$vault_name"
}

function add_secrets_to_vault() {
    local vault_name=$1
    local seed_repository=$2
    local full_seed_project_name=$3
    local billing_account_id=$4
    local postfix=$5
    local item_title="kh-gcp-bootstrap"

    echo "Adding items to 1Password vault $vault_name"
    archive_item_if_exists "$vault_name"  "$item_title" 
    
    op item create \
            --vault "$vault_name" \
            --category=login \
            --title="$item_title" \
            seed_repository="$seed_repository" \
            seed_project_name="$seed_project_name" \
            gcp_billing_account_id="$billing_account_id" \
            gcp_resource_postfix="$postfix" 

    echo "Items successfully added to vault $vault_name"
}

main "$SEED_PROJECT_NAME" "$POSTFIX" "$DEFAULT_REGION" "$BILLING_ACCOUNT" "$SEED_REPOSITORY_NAME" "$ONEPW_VAULT_NAME"
