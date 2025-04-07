#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/projects.sh"
source "$(dirname "$0")/support-functions.sh"

confirm "Really delete the projects?" || exit

# since Terraform cannot create projects without an organization,
# we use gcloud cli for the time being
for project in "${PROJECTS[@]}"; do
    echo "Project: ${project}-${POSTFIX}"

    gcloud projects delete "${project}-${POSTFIX}"
done
