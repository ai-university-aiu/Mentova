#!/usr/bin/env bash
# mentova_chat_start.sh — Start the Mentova Web Chat Server
#
# Usage:
#   bash bin/mentova_chat_start.sh [PORT] [DATA_DIR]
#
# Defaults:
#   PORT     = 8080
#   DATA_DIR = <repo_root>/data/chat_db
#
# Example:
#   bash bin/mentova_chat_start.sh 8080
#
# The server serves:
#   GET  /          — public chat page
#   GET  /mentor    — mentor panel
#   POST /api/chat  — chat endpoint
#   GET  /api/why   — justification endpoint
#   POST /api/mentor/login, /logout, /teach, /approve, /queue

PORT="${1:-8080}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DATA_DIR="${2:-${REPO_ROOT}/data/chat_db}"

exec swipl \
  -l "${REPO_ROOT}/src/mentova/mentova_chat.pl" \
  -g "mc_db_init('${DATA_DIR}'), mc_start_server(${PORT}), thread_get_message(shutdown)" \
  -t halt
