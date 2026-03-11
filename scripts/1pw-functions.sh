#!/usr/bin/env bash
# shellcheck disable=SC2155

function vault_exists() {
    local vault_name="$1"

    op vault get "$vault_name" >/dev/null 2>&1
}

function item_exists_in_vault() {
    local vault_name="$1"
    local item_title="$2"

    op item get "$item_title" --vault "$vault_name" >/dev/null 2>&1
}

function archive_item_in_vault() {
    local vault_name=$1
    local title=$2

    op item delete \
        --vault "$vault_name" \
        "$title" \
        --archive
}

function archive_item_if_exists() {
    local vault_name=$1
    local title=$2

    if item_exists_in_vault "$vault_name" "$title"; then
        echo "Item $title exists in vault $vault_name, archiving it"
        archive_item_in_vault "$vault_name" "$title"
    fi
}
