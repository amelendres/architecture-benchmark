#!/usr/bin/env bash
set -euo pipefail

USER=${1:-"bojand"} #fortio
REPO=${2:-"ghz"}    #fortio
TMP_TARGET=${3:-""} #usr/bin/

REPO_URL="https://api.github.com/repos/$USER/$REPO/releases/latest"
TOOL=$REPO

# install
PACKAGE_URL=$(wget --output-document - --quiet $REPO_URL | jq -r '.assets[] | select(.name|test("linux.*(amd64|x86_64)|linux_amd64")) | .browser_download_url' | head -n1)

if [ -n "$PACKAGE_URL" ]; then
    echo "Downloading '$PACKAGE_URL'"
    wget --output-document=/tmp/$TOOL.tgz --quiet "$PACKAGE_URL"
    tar -xzf /tmp/$TOOL.tgz -C /tmp || true
    if [ -x /tmp/$TMP_TARGET$TOOL ]; then sudo mv /tmp/$TMP_TARGET$TOOL /usr/local/bin/$TOOL && sudo chmod +x /usr/local/bin/$TOOL; fi
else
    echo "Failed to get '$PACKAGE_URL' from '$REPO_URL'" >&2
    exit 1
fi

command -v $TOOL >/dev/null || { echo "$TOOL required"; exit 1; }
