#\!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/gcp-functions.sh"
source "$(dirname "$0")/projects.sh"
source "$(dirname "$0")/support-functions.sh"

function main() {
    confirm "Really delete the projects?" || exit

    # since Terraform cannot create projects without an organization,
    # we use gcloud cli for the time being
    for project in "${PROJECTS[@]}"; do
        local full_project_name="${project}-${POSTFIX}"

        if \! project_exists "$full_project_name"; then
            echo "Project $full_project_name does not exist, skipping"
            continue
        fi

        echo "Deleting project: $full_project_name"
        gcloud projects delete "$full_project_name"
    done
}

main
