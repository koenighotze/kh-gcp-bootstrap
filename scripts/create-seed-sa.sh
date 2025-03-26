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

function main() {
    local full_seed_project_name=$1
    local sa_id=$2
    local seed_repository=$3
    local billing_account=$4
    local sa_email_address=$5

    create_seed_sa "$full_seed_project_name" "$sa_id"

    create_iam_bindings "$full_seed_project_name" "$billing_account" "$sa_email_address"

    setup_github_secrets "$seed_repository" "$sa_email_address"

    echo "Seed SA: $sa_email_address"
}

function setup_github_secrets() {
    local repository=$1
    local sa_email=$2

    echo "Storing service account email in GitHub secrets of repository $repository"

    gh secret set SEED_SA_EMAIL_ADDRESS -R "${repository}" -b "${sa_email}"
}

function create_iam_bindings() {
    local project=$1
    local billing_account=$2
    local sa_email=$3

    echo "Creating IAM bindings for $sa_email in seed project $project"

    ROLES=(
        "roles/iam.serviceAccountCreator"
        "roles/iam.serviceAccountDeleter"
        "roles/storage.admin"
        "roles/storage.objectAdmin"
    )

    for role in "${ROLES[@]}"; do
        gcloud projects add-iam-policy-binding \
            "$project" \
            --member="serviceAccount:$sa_email" \
            --role="$role"
    done

    gcloud billing accounts add-iam-policy-binding "${billing_account}" \
        --project="$project" \
        --member="serviceAccount:$sa_email" \
        --role="roles/billing.admin"
}

function create_seed_sa() {
    local project=$1
    local sa_id=$2

    if service_account_exists "$project"; then
        echo "Service account $sa_id already exists in project $project, will not create"
        return
    fi

    echo "Creating seed service account $sa_id in project $project"

    gcloud iam service-accounts create "$sa_id" \
        --project="$project" \
        --display-name "Seed account for Koenighotze"
}

# shellcheck disable=SC2153
main "${SEED_PROJECT_NAME}-${POSTFIX}" "${SEED_SA_ID}" "$SEED_REPOSITORY_NAME" "$BILLING_ACCOUNT" "$SEED_SA_EMAIL_ADDRESS"
