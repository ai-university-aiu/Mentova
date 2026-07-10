#!/usr/bin/env bash
# mentova-chat-update.sh
# Pull the latest code from origin/main.
# Restart mentova-chat if any files changed.

set -euo pipefail

cd /home/ccaitwo/Mentova

BEFORE=$(git rev-parse HEAD)

git fetch origin main --quiet 2>/dev/null

REMOTE=$(git rev-parse origin/main)

if [ "$BEFORE" != "$REMOTE" ]; then
    git pull --rebase --quiet
    systemctl --user restart mentova-chat
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) updated $BEFORE -> $REMOTE, restarted mentova-chat"
fi
