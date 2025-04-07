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
source "$(dirname "$0")/projects.sh"

function main() {
    local postfix=$1
    local billing_account=$2

    for project in "${PROJECTS[@]}"; do
        create_project "$project" "$postfix" "$billing_account"
    done
}

function create_project() {
    local project_name="$1"
    local postfix="$2"
    local billing_account="$3"

    local project_id="${project_name}-${postfix}"

    create_project_unless_exists "$project_id"
    enable_billing "$project_id" "$billing_account"

    echo "Finished with project $project_id"
}

# shellcheck disable=SC2153
main "$POSTFIX" "$BILLING_ACCOUNT"
