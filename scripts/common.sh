#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034
# when a command fails, bash exits instead of continuing with the rest of the script
set -o errexit
# make the script fail, when accessing an unset variable
set -o nounset
# pipeline command is treated as failed, even if one command in the pipeline fails
set -o pipefail
# enable debug mode, by running your script as TRACE=1
if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

source "$(dirname "$0")/local.sh"

# some random id to make projects and other resources unique, but grouped
DEFAULT_REGION=europe-west3
POSTFIX="13bf3f03"
SEED_PROJECT_NAME="kh-gcp-seed"
FULL_SEED_PROJECT_NAME="${SEED_PROJECT_NAME}-${POSTFIX}"
SEED_REPOSITORY_NAME="koenighotze/kh-gcp-seed"
BILLING_ACCOUNT=$(gcloud billing accounts list --filter="displayName=DSchmitz-Training-Billing" --format="value(name)")
ONEPW_VAULT_NAME="kh-development"

SEED_SA_ID=koenighotze-seed-sa
SEED_SA_EMAIL_ADDRESS="${SEED_SA_ID}@${FULL_SEED_PROJECT_NAME}.iam.gserviceaccount.com"
