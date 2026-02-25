# OpenClaw GCP — Agent shortcut & manual steps

**Main entry:** [README.md](README.md) — start there. This file is the full runbook with every copy-paste block.

Use this when an **agentic coder** (Cursor, etc.) is connected to your GCP VM via SSH. Copy-paste the blocks below for the agent; do the **manual** steps yourself.

---

## 1. You do (local Windows): connect

**One-time sign-in:**
```powershell
gcloud auth login
```

**Connect to VM** (replace instance, zone, project if needed):
```powershell
cd F:\Openclaw
.\gcp-ssh.cmd open-claw us-central1-c project-d87940eb-76c3-4f93-917
```

Or with gcloud directly:
```powershell
gcloud config set project project-d87940eb-76c3-4f93-917
gcloud compute ssh open-claw --zone=us-central1-c
```

**Tell your agent:** “I’m connected via SSH to the GCP VM. Use AGENT-SHORTCUT.md in the repo — run the agent blocks; I’ll do the manual steps.”

---

## 2. Agent: copy-paste blocks (run on the VM)

Replace `OPENCLAW_HOME` with the real path (e.g. `/home/rikinshah787/.openclaw` or `$HOME/.openclaw`). Replace `OPENCLAW_USER` with the user who runs Docker (e.g. `rikinshah787`).

### 2a. Clone repo on VM (if not already)
```bash
cd ~
git clone https://github.com/Rikinshah787/Openclaw-in-GCP-Setup.git openclaw-setup
cd openclaw-setup
```

### 2b. Full VM setup (Docker + Tailscale + OpenClaw + permissions)
```bash
chmod +x scripts/vm-setup.sh scripts/openclaw-fix-permissions.sh scripts/tailscale-funnel.sh
./scripts/vm-setup.sh
```

### 2c. Fix OpenClaw permissions (if EACCES / permission denied)
```bash
./scripts/openclaw-fix-permissions.sh /home/OPENCLAW_USER/.openclaw
# Or: ./scripts/openclaw-fix-permissions.sh   (uses $HOME/.openclaw)
```

### 2d. Enable Tailscale Funnel (HTTPS dashboard)
```bash
./scripts/tailscale-funnel.sh
# Or: sudo tailscale funnel --bg --yes http://127.0.0.1:18789
```

### 2e. Get gateway token (for client / dashboard)
```bash
sudo cat /home/OPENCLAW_USER/.openclaw/openclaw.json | grep -A1 '"token"'
```

### 2f. Restart gateway (after .env or config change)
```bash
sudo docker restart openclaw-gateway
```

### 2g. Approve device pairing (when client shows “pairing required”)
```bash
sudo docker run --rm --network host -v /home/OPENCLAW_USER/.openclaw:/home/node/.openclaw ghcr.io/phioranex/openclaw-docker:latest devices approve REQUEST_ID
```
(Replace `REQUEST_ID` with the ID shown on the gateway/dashboard.)

### 2h. Approve Telegram pairing (when user has a pairing code)
```bash
sudo docker run --rm --network host -v /home/OPENCLAW_USER/.openclaw:/home/node/.openclaw ghcr.io/phioranex/openclaw-docker:latest pairing approve telegram PAIRING_CODE
```
(Replace `PAIRING_CODE` with the code the user received.)

---

## 3. Manual only (you do these — agent cannot)

- **Tailscale first-time:** After `tailscale up`, open the **auth link** in your browser and approve the machine in your Tailscale admin. Done once per VM.

- **OAuth (e.g. OpenAI Codex):**  
  1. On the VM, run the login command (agent can run it).  
  2. The CLI will print an OAuth URL. **You** open that URL in **your** browser and sign in.  
  3. After redirect, the address bar will show something like `http://localhost:1455/auth/callback?code=...&state=...`. **Copy the full URL**.  
  4. **Paste** that URL into the SSH terminal where the CLI is waiting and press Enter.  
  5. Agent can then run: `sudo docker restart openclaw-gateway`.

- **API keys (.env):** You paste your real keys into `.env` on the VM (agent can open the file with `nano`; you paste and save). Do not paste keys into the chat.

- **Client / dashboard:** You open the dashboard URL (Tailscale Funnel or `http://VM_IP:18789`) and **paste the gateway token** when asked. Agent can print the token (block 2e); you paste it in the browser/app.

- **Done:** Once token is in the client and Funnel is on, you’re done.

---

## Quick reference

| Need | Agent runs | You do |
|------|------------|--------|
| First-time VM setup | 2a, 2b | Tailscale auth link in browser |
| Permission errors | 2c | — |
| HTTPS dashboard | 2d | — |
| Get token for client | 2e | Paste token in dashboard/app |
| After .env / config change | 2f | — |
| New device pairing | 2g | — |
| Telegram pairing | 2h | — |
| OAuth (OpenAI/Anthropic) | Run login command | Open URL → sign in → copy callback URL → paste in terminal |
| API keys | Open .env with nano | Paste keys, save |
