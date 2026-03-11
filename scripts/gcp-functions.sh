#!/usr/bin/env bash
# shellcheck disable=SC1091

function service_account_exists() {
    local project_id="$1"
    local sa_email="$2"
    local existing_sa
    existing_sa=$(gcloud iam service-accounts list --project="$project_id" --filter="email=$sa_email" --format="value(email)")

    if [ -z "$existing_sa" ]; then
        return 1
    else
        return 0
    fi
}

function project_exists() {
    local project_id="$1"
    local existing_project
    existing_project=$(gcloud projects list --filter=PROJECT_ID="$project_id" --format="value(PROJECT_ID)")

    if [ -z "$existing_project" ]; then
        return 1
    else
        return 0
    fi
}

function bucket_exists() {
    local bucket_name="$1"
    local project="$2"
    local existing_bucket
    existing_bucket=$(gcloud storage buckets list --filter=name="$bucket_name" --format="value(name)" --project="$project")

    if [ -z "$existing_bucket" ]; then
        return 1
    else
        return 0
    fi
}

function create_project_unless_exists() {
    local project_id="$1"

    echo "Creating project $project_id"

    if project_exists "$project_id"; then
        echo "Project $project_id already exists, will not create"
    else
        display_name=$(echo "Koenighotze $project_id" | cut -c 1-30)

        gcloud projects create "${project_id}" --name="$display_name"
    fi
}

function enable_billing() {
    local project_id="$1"
    local billing_account="$2"

    echo "Enabling billing account $billing_account for project $project_id"

    gcloud billing projects link "${project_id}" --billing-account="${billing_account}"
}
