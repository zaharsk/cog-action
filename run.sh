#!/usr/bin/env bash
# CONFIG="./cog.toml" VERBOSE="DEFAULT" CMD="check" ARGS="" ./run.sh

set -ueo pipefail

RED=$'\e[31m'
BLUE=$'\e[34m'
RESET=$'\e[0m'

err() {
    printf '%s\n' "${RED}(!) Error:${RESET} $*" >&2
}

info() {
    printf '%s\n' "${BLUE}(!) Info:${RESET} $*" >&2
}

if [[ -z "${GITHUB_OUTPUT:-}" ]]; then
    GITHUB_OUTPUT="$(mktemp)"
    LOCAL_RUN="true"
    info "Using local GITHUB_OUTPUT: $GITHUB_OUTPUT"
fi

CONFIG="${CONFIG:-}"
VERBOSE="${VERBOSE:-}"
CMD="${CMD:-}"
ARGS="${ARGS:-}"

if [ -z "$CMD" ]; then
    err "No cmd provided"
    exit 1
fi

case "${VERBOSE}" in
DEFAULT)
    VERBOSE=""
    ;;
ERROR)
    VERBOSE="-v"
    ;;
WARNING)
    VERBOSE="-vv"
    ;;
INFO)
    VERBOSE="-vvv"
    ;;
*)
    err "Unsupported level of verbosity: ${VERBOSE}"
    exit 1
    ;;
esac

TAG_PREFIX=""
# if [[ -f "$CONFIG" ]]; then
#     CONFIG_TAG_PREFIX=$(grep -E "tag_prefix" "$CONFIG" | tr -d '"') || true
#     TAG_PREFIX="${CONFIG_TAG_PREFIX##*= }"
# fi

if [[ -f "$CONFIG" ]]; then
    TAG_PREFIX="$(
        sed -nE 's/^[[:space:]]*tag_prefix[[:space:]]*=[[:space:]]*"([^"]*)".*/\1/p' "$CONFIG"
    )"
fi

info "Run: cog --config $CONFIG $VERBOSE $CMD $ARGS"

VERSION_BEFORE_RUN="$(cog -v get-version --fallback 0.0.1)"
TMP="$(mktemp)"
cog --config $CONFIG $VERBOSE $CMD $ARGS >$TMP

if [ "$CMD" = "changelog" ]; then
    {
        echo "changelog<<EOF"
        cat "$TMP"
        echo "EOF"

    } >>"$GITHUB_OUTPUT"
fi

CURRENT_VERSION="$(cog -v get-version --fallback 0.0.1)"

if [[ "${CURRENT_VERSION}" != "${VERSION_BEFORE_RUN}" ]]; then
    BUMPED="true"
fi

echo "bumped="${BUMPED:-false}"" >>"$GITHUB_OUTPUT"
echo "version=$CURRENT_VERSION" >>"$GITHUB_OUTPUT"
echo "tag=${TAG_PREFIX}${CURRENT_VERSION}" >>"$GITHUB_OUTPUT"

if [[ "${LOCAL_RUN:-false}" == "true" ]]; then
    cat "$GITHUB_OUTPUT"
fi
