# GCP SSH + OpenClaw helper (reference)

PowerShell scripts and notes to connect to a GCP VM via SSH and run [OpenClaw](https://docs.openclaw.ai) (gateway, dashboard, Telegram, etc.).

## Full setup (VM → SSH → Tailscale → OpenClaw → client)

**New to GCP or OpenClaw?** Follow **[GCP-SETUP.md](GCP-SETUP.md)** for the full path:

1. **Create a VM** (gcloud or Console) and allow SSH (firewall).
2. **Use this repo's script** to connect: `.\gcp-ssh.cmd`.
3. **On the VM:** Install Docker → Tailscale → OpenClaw gateway (install.sh).
4. **Firewall** for OpenClaw port 18789 (and optional Tailscale Funnel).
5. **On your client:** Open dashboard or OpenClaw app, paste gateway token, done.

Then come back to the main [README](README.md) for the agent shortcut.

---

## Quick start (you already have a VM)

1. **Install Google Cloud SDK** (one time)  
   [Install guide](https://cloud.google.com/sdk/docs/install) or:
   ```powershell
   winget install Google.CloudSDK
   ```

2. **Sign in**
   ```powershell
   gcloud auth login
   ```

3. **Connect**
   - List VMs and get the SSH command:
     ```powershell
   .\gcp-ssh.cmd
   ```
   - Or connect directly (use your instance name, zone, project):
     ```powershell
   .\gcp-ssh.cmd INSTANCE_NAME ZONE PROJECT_ID
   ```
     Example: `.\gcp-ssh.cmd my-vm us-central1-a my-project-id`

**If PowerShell blocks scripts**, use the `.cmd` launcher (no execution policy change needed):
```powershell
.\gcp-ssh.cmd
```

## What's in this repo

| File | Purpose |
|------|--------|
| `gcp-ssh.ps1` | Main script: checks auth, lists VMs, runs `gcloud compute ssh` |
| `gcp-ssh.cmd` | Launcher that runs the script with execution policy bypass |
| **`GCP-SETUP.md`** | **Full guide: create VM → firewall → SSH → Tailscale → OpenClaw → client** |
| **`AGENT-SHORTCUT.md`** | **Full copy-paste runbook for agents + manual-only steps** |
| `GCP-SSH-README.md` | Detailed runbook: API keys, OAuth, Tailscale, Telegram pairing, etc. |
| `scripts/create-vm.sh` | Create GCP VM + firewall (SSH + 18789); run locally (WSL/Git Bash/Linux) |
| `scripts/vm-setup.sh` | On-VM: install Docker, Tailscale, OpenClaw, fix permissions |
| `scripts/openclaw-fix-permissions.sh` | Fix `.openclaw` ownership (1000:1000) to avoid EACCES |
| `scripts/tailscale-funnel.sh` | Enable Tailscale Funnel for dashboard (127.0.0.1:18789) |

Optional / reference:

- `openclaw.env.template` – template for `OPENAI_API_KEY` / `ANTHROPIC_API_KEY` on the VM.
- `tailscale-funnel-openclaw.service` – systemd unit to keep Tailscale Funnel for the dashboard on after reboot.
- `docker-compose-fixed.yml` – example compose with gateway + env_file for OpenClaw.

## Requirements

- Windows (PowerShell)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed (adds `gcloud`)
- A GCP project with a Compute Engine VM and SSH access

**Before pushing to GitHub:** Don't commit `.env`, `auth-profiles.json`, or any file with API keys or tokens. `.gitignore` is set up to exclude those.

## License

Use and adapt as you like. No warranty.
