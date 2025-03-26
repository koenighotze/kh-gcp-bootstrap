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
POSTFIX="13bf3f03"
DEFAULT_REGION=europe-west3
SEED_PROJECT_NAME="kh-gcp-seed"
SEED_REPOSITORY_NAME="koenighotze/kh-gcp-seed"
BILLING_ACCOUNT=$(gcloud billing accounts list --filter="displayName=DSchmitz-Training-Billing" --format="value(name)")
ONEPW_VAULT_NAME="kh-development"

#SA_ID=koenighotze-seed-sa
#SA_EMAIL="${SA_ID}@${SEED_PROJECT}.iam.gserviceaccount.com"
