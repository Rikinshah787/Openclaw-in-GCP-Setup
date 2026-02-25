#!/usr/bin/env bash
# Enable Tailscale Funnel so the OpenClaw dashboard is reachable via HTTPS.
# Run ON THE GCP VM after Tailscale is up and OpenClaw gateway is running.
# Usage: ./scripts/tailscale-funnel.sh

set -e
echo "Enabling Tailscale Funnel for http://127.0.0.1:18789"
sudo tailscale funnel off 2>/dev/null || true
sudo tailscale funnel --bg --yes http://127.0.0.1:18789
echo "Funnel is on. Use the URL shown by: tailscale funnel status"
