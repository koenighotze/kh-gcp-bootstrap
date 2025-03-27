#!/usr/bin/env bash
# when a command fails, bash exits instead of continuing with the rest of the script
set -o errexit
# make the script fail, when accessing an unset variable
set -o nounset
# pipeline command is treated as failed, even if one command in the pipeline fails
set -o pipefail
# enable debug mode, by running your script as TRACE=1
if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

# op item list --vault kh-development --format=json --tags common | jq '.[] | .id,.title'
ONEPW_CODACY_API_TOKEN_ID="op://kh-development/Codacy/token"
ONEPW_DOCKER_REGISTRY_USERNAME_ID="op://kh-development/Docker-github-workflow-actions/username"
ONEPW_DOCKER_REGISTRY_TOKEN_ID="op://kh-development/Docker-github-workflow-actions/password"