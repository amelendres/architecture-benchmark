#!/usr/bin/env bash
set -euo pipefail

USER=${1:-"fortio"}
REPO=${2:-"fortio"}
REPO_URL=${1:-"https://api.github.com/repos/$USER/$REPO/releases/latest"}
TOOL=$REPO

# install
PACKAGE_URL=$(curl -s $REPO_URL | jq -r '.assets[] | select(.name|test("linux.*(amd64|x86_64)|linux_amd64")) | .browser_download_url' | head -n1)
if [ -n "$PACKAGE_URL" ]; then
    curl -sL "$PACKAGE_URL" -o /tmp/$TOOL.tgz
    tar -xzf /tmp/$TOOL.tgz -C /tmp || true
    if [ -x /tmp/usr/bin/$TOOL ]; then sudo mv /tmp/usr/bin/$TOOL /usr/local/bin/$TOOL && sudo chmod +x /usr/local/bin/$TOOL; fi
else
    echo "Failed to get '$PACKAGE_URL' from '$REPO_URL'" >&2
    exit 1
fi

command -v $TOOL >/dev/null || { echo "$TOOL required"; exit 1; }
