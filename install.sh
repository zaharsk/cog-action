#!/usr/bin/env bash

set -ueo pipefail

ARCH=$(uname -m)
BINPATH="/usr/local/bin"
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

RED=$'\e[31m'
BLUE=$'\e[34m'
RESET=$'\e[0m'

err() {
    printf '%s\n' "${RED}(!) Error:${RESET} $*" >&2
}

info() {
    printf '%s\n' "${BLUE}(!) Info:${RESET} $*" >&2
}

### === ### === ### === ### === ### === ### === ### === ### === ### === ### ===

BIN="${BINPATH}/cog"

if command -v cog >/dev/null 2>&1; then
    info "$(cog --version) discovered"
    exit 0
fi

info "Start installation of Cocogitto on ${OS}/${ARCH}"

REPO_OWNER=cocogitto
REPO_NAME=cocogitto

COG_VERSION="${VERSION}"

if [ "$COG_VERSION" == "latest" ]; then
    RELEASE_INFO="$(curl -fsSL https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest)"
    COG_VERSION="$(echo "${RELEASE_INFO}" | jq -er .tag_name)"
    info "Latest version is ${COG_VERSION}"
else
    RELEASE_INFO="$(curl -fsSL https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${COG_VERSION})"
fi

DOWNLOAD_URL="$(echo "$RELEASE_INFO" |
    jq -er --arg arch "$ARCH" --arg os "$OS" \
        '.assets[] | select(.name | contains($arch) and contains($os)) | .browser_download_url')"

FILE_NAME="${DOWNLOAD_URL##*/}"
FILE_NAME="${FILE_NAME#cocogitto-${COG_VERSION}-}"
FOLDER_NAME="${FILE_NAME%.tar.gz}"

TMP_DIR="$(mktemp -d)"

curl -fsSL -o "${TMP_DIR}/${FILE_NAME}" "${DOWNLOAD_URL}"

tar -xf "${TMP_DIR}/${FILE_NAME}" -C "${TMP_DIR}"

sudo install -m 755 \
    "${TMP_DIR}/${FOLDER_NAME}/cog" \
    "${BIN}"

rm -rf "${TMP_DIR}"

info "Istallation of $(cog --version) finished"
