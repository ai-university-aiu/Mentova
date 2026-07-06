#!/usr/bin/env bash
# mentova-chat-install.sh
# Run once to install Mentova Chat as a persistent user systemd service.
# The server starts on boot and restarts automatically if it crashes.
# A timer checks GitHub every 60 seconds and restarts the server if new code arrives.
#
# Usage:
#   bash bin/mentova-chat-install.sh

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
UNIT_DIR="$HOME/.config/systemd/user"

echo "Installing Mentova Chat systemd services from: $REPO"

# Stop any manually started instance so systemd takes over cleanly.
pkill -f mentova_chat_start.sh 2>/dev/null && echo "Stopped existing server." || true

# Make the scripts executable.
chmod +x "$REPO/bin/mentova_chat_start.sh"
chmod +x "$REPO/bin/mentova-chat-update.sh"

# Create the user unit directory if it does not exist.
mkdir -p "$UNIT_DIR"

# Symlink unit files so updates to the repo are picked up automatically.
ln -sf "$REPO/bin/mentova-chat.service"        "$UNIT_DIR/mentova-chat.service"
ln -sf "$REPO/bin/mentova-chat-update.service" "$UNIT_DIR/mentova-chat-update.service"
ln -sf "$REPO/bin/mentova-chat-update.timer"   "$UNIT_DIR/mentova-chat-update.timer"

# Enable linger so user services keep running after logout.
loginctl enable-linger "$USER"

# Reload systemd and enable both units.
systemctl --user daemon-reload
systemctl --user enable mentova-chat
systemctl --user enable mentova-chat-update.timer
systemctl --user start  mentova-chat
systemctl --user start  mentova-chat-update.timer

echo ""
echo "Done. Mentova Chat is running and will start on every boot."
echo ""
echo "  Chat:     http://localhost:8088/"
echo "  Mentor:   http://localhost:8088/mentor"
echo ""
echo "  Status:   systemctl --user status mentova-chat"
echo "  Logs:     journalctl --user -u mentova-chat -f"
echo "  Updates:  pulled from GitHub every 60 seconds automatically"
echo "  Stop:     systemctl --user stop mentova-chat"
echo "  Restart:  systemctl --user restart mentova-chat"
