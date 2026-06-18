#!/usr/bin/env bash

set -ueo pipefail

if [[ ! -f .devcontainer/.env ]]; then
    cp .devcontainer/.env.example .devcontainer/.env
fi

### === ### === ### === ### === ### === ### === ### === ### === ### === ###
