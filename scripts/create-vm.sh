#!/usr/bin/env bash
# Create GCP VM and firewall rules for OpenClaw
# Run from local machine (WSL, Git Bash, or Linux) with gcloud installed and authenticated.
# Usage: ./scripts/create-vm.sh [PROJECT_ID] [ZONE] [VM_NAME]

set -e
PROJECT_ID="${1:-YOUR_PROJECT_ID}"
ZONE="${2:-us-central1-c}"
VM_NAME="${3:-openclaw-gateway}"

echo "Creating VM: $VM_NAME in $ZONE (project: $PROJECT_ID)"
if [[ "$PROJECT_ID" == "YOUR_PROJECT_ID" ]]; then
  echo "Replace YOUR_PROJECT_ID with your GCP project ID."
  exit 1
fi

gcloud config set project "$PROJECT_ID"

# Create VM (Debian 12, e2-small, 10 GB disk)
gcloud compute instances create "$VM_NAME" \
  --zone="$ZONE" \
  --machine-type=e2-small \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --boot-disk-size=10GB \
  --tags=openclaw,ssh

# Allow SSH (port 22)
gcloud compute firewall-rules create allow-ssh \
  --allow=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=ssh \
  --project="$PROJECT_ID" 2>/dev/null || echo "allow-ssh rule already exists"

# Allow OpenClaw gateway (port 18789)
gcloud compute firewall-rules create openclaw-gateway \
  --allow=tcp:18789 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=openclaw \
  --project="$PROJECT_ID" 2>/dev/null || echo "openclaw-gateway rule already exists"

echo ""
echo "Done. Connect with:"
echo "  gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID"
echo "Or use this repo's script: .\\gcp-ssh.cmd $VM_NAME $ZONE $PROJECT_ID"
