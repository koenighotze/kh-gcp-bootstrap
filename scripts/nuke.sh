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
source "$(dirname "$0")/support-functions.sh"

function build_managed_projects() {
    local -n result=$1

    result+=("${FULL_SEED_PROJECT_NAME}")

    for project in "${PROJECTS[@]}"; do
        result+=("${project}-${POSTFIX}")
    done
}

function is_managed() {
    local project_id=$1
    shift
    local managed=("$@")

    for managed_id in "${managed[@]}"; do
        if [[ "$project_id" == "$managed_id" ]]; then
            return 0
        fi
    done
    return 1
}

function confirm_by_name() {
    local project_id=$1

    read -r -p "Type the project name to confirm deletion [${project_id}]: " response
    [[ "$response" == "$project_id" ]]
}

function main() {
    local -a managed_projects=()
    build_managed_projects managed_projects

    echo "Managed projects (will not be touched):"
    for p in "${managed_projects[@]}"; do
        echo "  - $p"
    done
    echo

    local -a unmanaged=()
    while IFS= read -r project_id; do
        if ! is_managed "$project_id" "${managed_projects[@]}"; then
            unmanaged+=("$project_id")
        fi
    done < <(gcloud projects list --format="value(projectId)" --sort-by=projectId)

    if [[ ${#unmanaged[@]} -eq 0 ]]; then
        echo "No unmanaged projects found."
        return
    fi

    echo "Unmanaged projects found:"
    for p in "${unmanaged[@]}"; do
        echo "  - $p"
    done
    echo

    for project_id in "${unmanaged[@]}"; do
        echo "---"
        echo "Project: $project_id"

        if confirm_by_name "$project_id"; then
            echo "Deleting $project_id ..."
            gcloud projects delete "$project_id"
            echo "Deleted $project_id"
        else
            echo "Skipping $project_id"
        fi
    done
}

main
