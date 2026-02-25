# OpenClaw on GCP — Full setup guide

End-to-end: create a VM, open SSH with the firewall, install Tailscale + OpenClaw gateway, then connect from your client (easiest path).

---

## Prerequisites

- A [Google Cloud](https://cloud.google.com) account and a project.
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed on your **local machine** (Windows):
  ```powershell
  winget install Google.CloudSDK
  ```
- [Tailscale](https://tailscale.com) account (for optional HTTPS dashboard).

---

## Step 1 — Create a GCP VM

Use either the **gcloud** CLI, the **included script**, or the **Console**.

### Option A: Script (recommended)

From this repo (WSL, Git Bash, or Linux with `gcloud` installed):

```bash
chmod +x scripts/create-vm.sh
./scripts/create-vm.sh YOUR_PROJECT_ID us-central1-c openclaw-gateway
```

This creates the VM and firewall rules for SSH (22) and OpenClaw (18789). Replace `YOUR_PROJECT_ID` with your GCP project ID.

### Option B: gcloud CLI (manual)

In **PowerShell**:

```powershell
# Set your project
gcloud config set project YOUR_PROJECT_ID

# Create a VM (Debian, e2-small, 10 GB disk)
gcloud compute instances create openclaw-gateway `
  --zone=us-central1-c `
  --machine-type=e2-small `
  --image-family=debian-12 `
  --image-project=debian-cloud `
  --boot-disk-size=10GB `
  --tags=openclaw,ssh

# Ensure SSH firewall rule exists (default often has allow-ssh)
gcloud compute firewall-rules create allow-ssh `
  --allow=tcp:22 `
  --source-ranges=0.0.0.0/0 `
  --target-tags=ssh `
  --description="Allow SSH" 2>$null; echo "Done (ignore error if rule already exists)"
```

Replace `YOUR_PROJECT_ID` and adjust `zone` / `machine-type` if you like.

### Option C: Google Cloud Console

1. Go to [Compute Engine → VM instances](https://console.cloud.google.com/compute/instances).
2. **Create instance**.
3. Set name (e.g. `openclaw-gateway`), region/zone, machine type (e.g. e2-small).
4. Under **Firewall**, check **Allow HTTP/HTTPS** if you want; **SSH (22)** is usually allowed via “Allow default access” or an SSH rule.
5. Create. Note the **external IP** and **zone** (e.g. `us-central1-c`).

### Allow SSH (if not already)

If SSH fails, add a firewall rule:

```powershell
gcloud compute firewall-rules create allow-ssh `
  --allow=tcp:22 `
  --source-ranges=0.0.0.0/0 `
  --target-tags=ssh `
  --project=YOUR_PROJECT_ID
```

Attach tag `ssh` to your VM if you used a tag in the rule.

---

## Step 2 — Connect via SSH (use this repo’s script)

1. **Sign in** (one time):
   ```powershell
   gcloud auth login
   ```

2. **Clone or download this repo**, then from its folder:
   ```powershell
   .\gcp-ssh.cmd
   ```
   This lists your VMs and shows the exact SSH command.

3. **Connect** (replace with your instance name, zone, project):
   ```powershell
   .\gcp-ssh.cmd openclaw-gateway us-central1-c YOUR_PROJECT_ID
   ```
   Or set a default project once and omit the third argument:
   ```powershell
   gcloud config set project YOUR_PROJECT_ID
   .\gcp-ssh.cmd openclaw-gateway us-central1-c
   ```

You should be in an SSH session on the VM. Keep this terminal open for the next steps.

---

## Step 3 — On the VM: install Docker, Tailscale, OpenClaw

You can use the **included shell script** or run the commands manually.

### Option A: One script (recommended)

If you have this repo on the VM (e.g. cloned or copied), run:

```bash
chmod +x scripts/vm-setup.sh scripts/openclaw-fix-permissions.sh scripts/tailscale-funnel.sh
./scripts/vm-setup.sh
```

This installs Docker, Tailscale, and OpenClaw (via install.sh) and fixes `.openclaw` permissions. Then:

- Run `sudo tailscale up` and follow the auth link.
- After OpenClaw is running, enable Funnel: `./scripts/tailscale-funnel.sh`
- If you get permission errors later: `./scripts/openclaw-fix-permissions.sh` (or pass a path: `./scripts/openclaw-fix-permissions.sh /home/youruser/.openclaw`)

### Option B: Manual steps

Run these **on the VM** (in your SSH session). Commands are for **Debian/Ubuntu**; adapt for other distros if needed.

### 3.1 Install Docker

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER
# Log out and back in (or new SSH session) for docker without sudo
```

### 3.2 Install Tailscale (optional, for HTTPS dashboard)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
# Follow the auth link in the output to join your tailnet
```

### 3.3 Install OpenClaw gateway (Docker)

Use the [OpenClaw Docker](https://github.com/phioranex/openclaw-docker) one-liner:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/phioranex/openclaw-docker/main/install.sh)
```

- When asked, complete the **onboarding** (model/auth, e.g. OpenAI Codex OAuth or API key).
- If the script uses `~/.openclaw`, ensure that directory is writable by the container:
  ```bash
  sudo chown -R 1000:1000 ~/.openclaw
  ```
  (Use the home of the user who runs `docker compose`; if you run as root, replace with the actual path, e.g. `/home/youruser/.openclaw`.)

### 3.4 Open firewall for OpenClaw (if you use external IP)

To reach the gateway on port 18789 from the internet:

```bash
# From your LOCAL machine (PowerShell), not on the VM:
gcloud compute firewall-rules create openclaw-gateway --allow=tcp:18789 --source-ranges=0.0.0.0/0 --project=YOUR_PROJECT_ID
```

Or in **Console**: VPC network → Firewall → Create rule, allow `tcp:18789`, target tags as needed.

### 3.5 (Optional) Tailscale Funnel for HTTPS dashboard

On the VM, after Tailscale is up, either run the script or the command:

```bash
./scripts/tailscale-funnel.sh
# or:
sudo tailscale funnel --bg --yes http://127.0.0.1:18789
```

Note the Funnel URL (e.g. `https://your-machine.tailxxxx.ts.net`). Use it to open the dashboard in a browser.

---

## Step 4 — Get gateway token and dashboard URL

On the VM:

```bash
# Show gateway token (paste this into the client later)
sudo cat ~/.openclaw/openclaw.json | grep -A1 '"token"'
```

Dashboard URLs:

- **Tailscale (HTTPS):** `https://YOUR_TAILSCALE_HOSTNAME.tailxxxx.ts.net` (from Funnel step).
- **Direct IP:** `http://VM_EXTERNAL_IP:18789` (if firewall allows 18789).

---

## Step 5 — Client: connect to OpenClaw (easiest way)

On your **client machine** (Windows, Mac, or Linux):

### Option A — Browser (simplest)

1. Open the **dashboard URL** (Tailscale or `http://VM_IP:18789`).
2. When asked for the gateway token, paste the token from Step 4.
3. Use the Control UI to chat and manage the agent.

### Option B — OpenClaw client (desktop / CLI)

1. Install OpenClaw on the client:
   - **Windows:** [OpenClaw releases](https://github.com/openclaw/openclaw/releases) or `winget install OpenClaw.Cursor` if available.
   - **macOS:** `brew install openclaw` or download from releases.
   - **CLI:** `npm install -g openclaw` or use the official install script.
2. Point the client at your gateway:
   - **Tailscale:** gateway URL = `ws://YOUR_TAILSCALE_IP:18789` or the Funnel hostname (check OpenClaw client docs for HTTPS/WS).
   - **Direct:** `ws://VM_EXTERNAL_IP:18789`.
3. When prompted, paste the **gateway token** from Step 4.
4. Approve the device if the gateway shows “pairing required”:
   ```bash
   # On the VM:
   sudo docker run --rm --network host -v /path/to/.openclaw:/home/node/.openclaw ghcr.io/phioranex/openclaw-docker:latest devices approve REQUEST_ID
   ```

### Telegram / other channels

- In the dashboard or config, add your Telegram bot token and enable the channel.
- When a user gets a **pairing code**, approve it on the VM:
  ```bash
  sudo docker run --rm --network host -v /path/to/.openclaw:/home/node/.openclaw ghcr.io/phioranex/openclaw-docker:latest pairing approve telegram PAIRING_CODE
  ```
  Replace `/path/to/.openclaw` with the real path (e.g. `/home/youruser/.openclaw`).

---

## Summary

| Step | Where        | Action |
|------|--------------|--------|
| 1    | Local        | Create GCP VM; ensure firewall allows SSH (port 22). |
| 2    | Local        | Use this repo’s `.\gcp-ssh.cmd` to connect to the VM. |
| 3    | VM           | Install Docker → Tailscale (optional) → OpenClaw via install.sh; open firewall for 18789 if needed; optionally start Tailscale Funnel. |
| 4    | VM           | Get gateway token and dashboard URL. |
| 5    | Client       | Open dashboard in browser or install OpenClaw client; paste token and connect. |

For more detail (API keys, OAuth, pairing, Tailscale), see **GCP-SSH-README.md** in this repo.

---

**Repo:** [OpenClaw in GCP Setup](https://github.com/YOUR_USERNAME/openclaw-gcp-setup) — clone and run `.\gcp-ssh.cmd` after Step 1.
