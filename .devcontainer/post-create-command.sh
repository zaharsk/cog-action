#!/usr/bin/env bash

set -ueo pipefail

echo "${GIT_PUBLIC_KEY}" > ~/.ssh/id_ed25519.pub

git config --global user.name "${GIT_USER_NAME}"
git config --global user.email "${GIT_USER_EMAIL}"
git config --global user.signingkey ~/.ssh/id_ed25519.pub

git config --global gpg.format ssh
git config --global commit.gpgsign true

git config --global pull.rebase true
git config --global merge.ff only

git config --global init.defaultBranch main

git config core.hooksPath .githooks

### === ### === ### === ### === ### === ### === ### === ### === ### === ### === ###