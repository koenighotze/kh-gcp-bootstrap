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

function vault_exists() {
    local vault_name="$1"
    local existing_vault
    
    op vault get "$vault_name" >/dev/null 2>&1

    return $?
}

function item_exists_in_vault() {
    local vault_name="$1"
    local item_title="$2"

    op item get "$item_title" --vault "$vault_name" >/dev/null 2>&1

    return $?
}

function archive_item_in_vault() {
    local vault_name=$1
    local title=$2
    local new_name="$title-prev-$(date +%s)"

    op item edit "$title" --title "$new_name" > /dev/null
    op item delete \
            --vault "$vault_name" \
            "$new_name"\
            --archive 
} 

function archive_item_if_exists() {
    local vault_name=$1
    local title=$2
    
    if item_exists_in_vault "$vault_name" "$title" 
    then
        echo "Item $title exists in vault $vault_name, archiving it"
        archive_item_in_vault "$vault_name" "$title"
    fi
}
