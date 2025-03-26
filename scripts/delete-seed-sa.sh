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
source "$(dirname "$0")/support-functions.sh"

confirm "Really delete the service account $SEED_SA_EMAIL_ADDRESS in project $FULL_SEED_PROJECT_NAME?" || exit

# this needs to be refactored once I have an organization
echo gcloud iam service-accounts delete "$SEED_SA_EMAIL_ADDRESS" --project "$FULL_SEED_PROJECT_NAME"

gh secret delete SEED_SA_EMAIL_ADDRESS -R "${SEED_REPOSITORY_NAME}" || echo "Secret SEED_SA_EMAIL_ADDRESS does not exist or could not be deleted."
