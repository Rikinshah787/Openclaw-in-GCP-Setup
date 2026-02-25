#!/usr/bin/env bash
# Run this ON THE GCP VM after SSH (Debian/Ubuntu).
# Installs Docker, Tailscale, OpenClaw gateway, and fixes permissions.
# Usage: bash vm-setup.sh [--skip-tailscale] [--skip-openclaw]

set -e
SKIP_TAILSCALE=false
SKIP_OPENCLAW=false
for arg in "$@"; do
  case $arg in
    --skip-tailscale) SKIP_TAILSCALE=true ;;
    --skip-openclaw) SKIP_OPENCLAW=true ;;
  esac
done

echo "=== Installing Docker ==="
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker "$USER" 2>/dev/null || true
echo "Docker installed. Log out and back in (or new SSH session) to run docker without sudo."

if [[ "$SKIP_TAILSCALE" != "true" ]]; then
  echo ""
  echo "=== Installing Tailscale ==="
  curl -fsSL https://tailscale.com/install.sh | sh
  echo "Run: sudo tailscale up   (and follow the auth link)"
fi

if [[ "$SKIP_OPENCLAW" != "true" ]]; then
  echo ""
  echo "=== Installing OpenClaw gateway (Docker) ==="
  bash <(curl -fsSL https://raw.githubusercontent.com/phioranex/openclaw-docker/main/install.sh)
  echo ""
  echo "=== Fixing permissions for OpenClaw container ==="
  OPENCLAW_DIR="${OPENCLAW_CONFIG_DIR:-$HOME/.openclaw}"
  if [[ -d "$OPENCLAW_DIR" ]]; then
    sudo chown -R 1000:1000 "$OPENCLAW_DIR"
    sudo chmod -R 775 "$OPENCLAW_DIR"
    echo "Set $OPENCLAW_DIR to 1000:1000"
  else
    echo "Create $OPENCLAW_DIR and run: sudo chown -R 1000:1000 $OPENCLAW_DIR"
  fi
fi

echo ""
echo "=== Done ==="
echo "Get gateway token: sudo cat ~/.openclaw/openclaw.json | grep -A1 '\"token\"'"
echo "Optional Tailscale Funnel: sudo tailscale funnel --bg --yes http://127.0.0.1:18789"
