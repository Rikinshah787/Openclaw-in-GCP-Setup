#!/usr/bin/env bash
# Run ON THE GCP VM after OpenClaw is installed.
# Fixes .openclaw permissions so the gateway container can write (avoids EACCES).
# Usage: ./scripts/openclaw-fix-permissions.sh [OPENCLAW_DIR]

set -e
OPENCLAW_DIR="${1:-$HOME/.openclaw}"
if [[ ! -d "$OPENCLAW_DIR" ]]; then
  echo "Directory not found: $OPENCLAW_DIR"
  echo "Usage: $0 /path/to/.openclaw"
  exit 1
fi
echo "Fixing permissions for $OPENCLAW_DIR (container user 1000:1000)"
sudo mkdir -p "$OPENCLAW_DIR/agents/main/agent"
sudo chown -R 1000:1000 "$OPENCLAW_DIR"
sudo chmod -R 775 "$OPENCLAW_DIR"
echo "Done. Restart gateway if needed: sudo docker restart openclaw-gateway"
