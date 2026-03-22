<p align="center">
  <strong>GCP SSH + OpenClaw Helper</strong>
</p>
<p align="center">
  <em>Run OpenClaw on a GCP VM — with your AI agent doing the heavy lifting.</em>
</p>

<p align="center">
  <a href="https://github.com/Rikinshah787/Openclaw-in-GCP-Setup/stargazers"><img src="https://img.shields.io/github/stars/Rikinshah787/Openclaw-in-GCP-Setup?style=flat-square&label=Stars" alt="GitHub stars"></a>
  <a href="https://docs.openclaw.ai"><img src="https://img.shields.io/badge/OpenClaw-gateway%20%7C%20dashboard%20%7C%20Telegram-8B5CF6?style=flat-square" alt="OpenClaw"></a>
  <a href="https://cloud.google.com"><img src="https://img.shields.io/badge/GCP-Compute%20Engine-4285F4?style=flat-square&logo=google-cloud" alt="GCP"></a>
</p>

-

## What this is

You connect **Cursor** (or any agentic coder) to your GCP VM via SSH. You run **one connect command** and tell the agent to use this repo. The agent runs the scripts and commands; you only do the things that need a human: **OAuth in the browser**, **Tailscale auth link**, **pasting the gateway token** into the dashboard. Done.

No long runbooks. No “now run this, now run that.” One shortcut file, copy-paste blocks, clear split: **agent runs ↔ you do.**

---

## Quick start

### 1. You: connect to the VM

**One-time:** sign in and connect (replace with your instance, zone, project):

```powershell
gcloud auth login
cd F:\Openclaw
.\gcp-ssh.cmd INSTANCE_NAME ZONE PROJECT_ID
```

Example: `.\gcp-ssh.cmd open-claw us-central1-c my-gcp-project-id`

Or with gcloud directly:

```powershell
gcloud config set project YOUR_PROJECT_ID
gcloud compute ssh YOUR_INSTANCE --zone=YOUR_ZONE
```

### 2. You: tell your agent

> **"I'm connected via SSH to the GCP VM. Use the README and AGENT-SHORTCUT.md in this repo — run the agent blocks; I'll do the manual steps (OAuth, Tailscale link, paste token)."**

### 3. Agent runs ↔ You do

| What you need | Agent runs (copy-paste on VM) | You do |
|---------------|-------------------------------|--------|
| **First-time setup** | Clone repo → `./scripts/vm-setup.sh` | Open **Tailscale auth link** in browser once |
| **Permission errors** | `./scripts/openclaw-fix-permissions.sh` | — |
| **HTTPS dashboard** | `./scripts/tailscale-funnel.sh` | — |
| **Gateway token** | `sudo cat ~/.openclaw/openclaw.json \| grep -A1 '"token"'` | **Paste token** in dashboard/app |
| **Restart after config** | `sudo docker restart openclaw-gateway` | — |
| **Device pairing** | `devices approve REQUEST_ID` (see runbook) | — |
| **Telegram pairing** | `pairing approve telegram CODE` (see runbook) | — |
| **OAuth (OpenAI/Codex)** | Runs login command, prints URL | **Open URL** → sign in → **copy callback URL** → paste in terminal |
| **API keys** | Opens `.env` with nano | **Paste keys**, save |

Full copy-paste commands and placeholders (`OPENCLAW_USER`, paths, etc.) are in **[AGENT-SHORTCUT.md](AGENT-SHORTCUT.md)**.

---

## Agent: copy-paste blocks (on the VM)

Replace `OPENCLAW_USER` with your VM user (e.g. `rikinshah787`).

**Clone and run full setup:**

```bash
cd ~
git clone https://github.com/Rikinshah787/Openclaw-in-GCP-Setup.git openclaw-setup
cd openclaw-setup
chmod +x scripts/*.sh
./scripts/vm-setup.sh
```

**Fix permissions (if you see EACCES):**

```bash
./scripts/openclaw-fix-permissions.sh /home/OPENCLAW_USER/.openclaw
```

**Enable Tailscale Funnel (HTTPS dashboard):**

```bash
./scripts/tailscale-funnel.sh
```

**Get gateway token (for the user to paste in client):**

```bash
sudo cat /home/OPENCLAW_USER/.openclaw/openclaw.json | grep -A1 '"token"'
```

More blocks (restart gateway, approve device, approve Telegram) → **[AGENT-SHORTCUT.md](AGENT-SHORTCUT.md)**.

---

## Manual-only (you — agent can’t do these)

- **Tailscale:** After `tailscale up`, open the **auth link** in your browser and approve the machine. Once per VM.
- **OAuth:** Agent runs the login command; **you** open the URL in your browser, sign in, then **copy the callback URL** from the address bar and paste it into the SSH session.
- **API keys:** Agent can open `.env`; **you** paste your keys and save.
- **Client:** **You** open the dashboard (Funnel URL or `http://VM_IP:18789`) and **paste the gateway token** when asked.

---

## Repo layout

| Resource | Description |
|----------|-------------|
| **[AGENT-SHORTCUT.md](AGENT-SHORTCUT.md)** | Full runbook: every copy-paste block + manual steps |
| **[GCP-SETUP.md](GCP-SETUP.md)** | Full guide: create VM → firewall → SSH → Tailscale → OpenClaw → client |
| **[DOCS.md](DOCS.md)** | GCP SSH helper reference (scripts, requirements, file list) |
| **`gcp-ssh.cmd`** / **`gcp-ssh.ps1`** | Connect to VM from Windows (list VMs, SSH) |
| **`scripts/*.sh`** | `create-vm.sh`, `vm-setup.sh`, `openclaw-fix-permissions.sh`, `tailscale-funnel.sh` |

---

## Requirements

- **Local:** Windows, [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (`gcloud`), this repo.
- **VM:** GCP Compute Engine instance with SSH access (create via [GCP-SETUP.md](GCP-SETUP.md) or `scripts/create-vm.sh`).

Don’t commit `.env`, `auth-profiles.json`, or any file with API keys or tokens (`.gitignore` is set).

---

<p align="center">
  <strong>If this saved you time, give it a ⭐</strong>
</p>

<p align="center">
  <sub>Use and adapt as you like. No warranty.</sub>
</p>
