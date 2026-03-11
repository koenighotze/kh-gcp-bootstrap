#!/usr/bin/env bash
# shellcheck disable=SC1091

function confirm() {
    local message="${1:-Are you sure?}"

    read -r -p "$message [y/N]?" response
    case "$response" in
        [yY][eE][sS] | [yY])
            true
            ;;
        *)
            false
            ;;
    esac
}
