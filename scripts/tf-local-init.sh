#!/usr/bin/env bash

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
gcloud config set project "$FULL_SEED_PROJECT_NAME"
gcloud auth application-default set-quota-project "$FULL_SEED_PROJECT_NAME"

# TODO reduce duplication with create-projects.sh
SEED_PROJECT_TF_STATE_BUCKET_NAME="${FULL_SEED_PROJECT_NAME}-tf-state"
# we assume gcloud to be downloaded and initialized
# gcloud init
# gcloud auth application-default login

echo "Check if $SEED_PROJECT_TF_STATE_BUCKET_NAME exists"
if bucket_exists "$SEED_PROJECT_TF_STATE_BUCKET_NAME" "$FULL_SEED_PROJECT_NAME"; then
    terraform init -backend-config="bucket=$SEED_PROJECT_TF_STATE_BUCKET_NAME" "$@"
else
    echo "Missing bucket '$SEED_PROJECT_TF_STATE_BUCKET_NAME'; cannot initialize backend"
    exit 1 
fi
