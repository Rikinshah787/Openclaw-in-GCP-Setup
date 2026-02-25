# GCP SSH – Quick steps

**Note:** The SDK path has a space (`Cloud SDK`). In PowerShell, always use **quotes** when typing it, e.g.  
`cd "C:\Users\rikin\AppData\Local\Google\Cloud SDK\google-cloud-sdk"`

## 1. Sign in (one time)

In **PowerShell** (in this folder or anywhere):

```powershell
& "$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd" auth login
```

- A browser window will open.
- Sign in with your Google account that has access to the GCP project.
- When asked “Enter the verification code”, copy the code from the browser and paste it into PowerShell, then press Enter.

## 2. List your VMs and connect

Run the helper **from F:\Openclaw**:

**If scripts are blocked**, use the `.cmd` launcher (no execution policy change needed):
```powershell
cd F:\Openclaw
.\gcp-ssh.cmd
```

Or run the script with bypass in PowerShell:
```powershell
cd F:\Openclaw
powershell -ExecutionPolicy Bypass -File .\gcp-ssh.ps1
```

**If scripts are allowed** (ExecutionPolicy RemoteSigned or Unrestricted):
```powershell
cd F:\Openclaw
.\gcp-ssh.ps1
```

This will:

- Use your existing login (or prompt you to run `gcloud auth login` again if needed).
- List your VM instances (name, zone, status, external IP).
- Show you the exact command to SSH.

## 3. SSH into a VM

After you see the list, run (with `.cmd` if you use it for the script):

```powershell
.\gcp-ssh.cmd INSTANCE_NAME ZONE [PROJECT_ID]
```
Or with bypass: `powershell -ExecutionPolicy Bypass -File .\gcp-ssh.ps1 INSTANCE_NAME ZONE [PROJECT_ID]`

Example:

```powershell
.\gcp-ssh.ps1 my-vm us-central1-a my-gcp-project-id
```

Or use `gcloud` directly (same as what the script runs):

```powershell
$env:Path = "$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin;$env:Path"
gcloud compute ssh INSTANCE_NAME --zone=ZONE --project=PROJECT_ID
```

## If you don’t have a default project

Set it once:

```powershell
gcloud config set project YOUR_PROJECT_ID
```

Then you can omit the project from the SSH command.

## Your instance

- **Instance:** `open-claw`
- **Zone:** `us-central1-c`
- **Project:** `project-d87940eb-76c3-4f93-917`
- **User:** `rikin`

Quick SSH (after setting default project once: `gcloud config set project project-d87940eb-76c3-4f93-917`):

```powershell
$env:Path = "$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin;$env:Path"
gcloud compute ssh open-claw --zone=us-central1-c
```

Or with the script: `.\gcp-ssh.cmd open-claw us-central1-c project-d87940eb-76c3-4f93-917`

---

## OpenClaw API keys (OpenAI / Anthropic)

The gateway is configured to read API keys from **`.env`** on the VM. To fix “No API key found for provider”:

1. **SSH into the VM** (see above).

2. **Edit the env file** (use your own keys; do not commit these):
   ```bash
   sudo nano /home/rikinshah787/.openclaw/.env
   ```
   Set at least one of these (no quotes around the value):
   ```bash
   OPENAI_API_KEY=sk-your-openai-key-here
   ANTHROPIC_API_KEY=sk-ant-your-anthropic-key-here
   ```
   Save (Ctrl+O, Enter) and exit (Ctrl+X).

3. **Restart the gateway** so it picks up the new keys:
   ```bash
   sudo docker restart openclaw-gateway
   ```

4. **Check auth** (optional):
   ```bash
   sudo docker run --rm --network host -v /home/rikinshah787/.openclaw:/home/node/.openclaw ghcr.io/phioranex/openclaw-docker:latest models status
   ```

The main agent uses **auth-profiles.json** at `~/.openclaw/agents/main/agent/auth-profiles.json` with profiles for `anthropic:default` and `openai:default`. Keys are taken from the container environment (loaded from `.env`).

---

## OpenClaw OAuth via install.sh / OpenAI Codex (get link → paste token)

To use **OpenAI Codex (ChatGPT OAuth)** or run the full **onboarding wizard** from `install.sh` and get an OAuth link so you can log in in the browser and paste the callback:

1. **SSH in with an interactive TTY** (required so the CLI can show the link and accept your paste):
   ```powershell
   $env:Path = "$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin;$env:Path"
   gcloud compute ssh open-claw --zone=us-central1-c --project=project-d87940eb-76c3-4f93-917 --ssh-flag=-t
   ```
   On Windows use **`--ssh-flag=-t`** (not `-- -t`). Or omit it and try; the session may already be interactive.

2. **On the VM**, run **one** of these:

   **Option A – Onboarding wizard (like install.sh):**
   ```bash
   cd /home/rikinshah787/openclaw-docker && docker compose run --rm openclaw-cli onboard
   ```
   Go through the prompts; when it asks for auth, choose **OpenAI Codex (OAuth)**. It will show or open the OAuth URL.

   **Option B – Only OpenAI Codex login:**
   ```bash
   sudo docker run --rm -it -v /home/rikinshah787/.openclaw:/home/node/.openclaw --network host ghcr.io/phioranex/openclaw-docker:latest models auth login --provider openai-codex
   ```

3. **Get the link**  
   The CLI will print (or try to open) the OAuth URL, e.g.  
   `https://auth.openai.com/oauth/authorize?response_type=code&...`  
   If it doesn’t open on the server, **copy that URL** from the terminal.

4. **Open the URL on your machine** (same browser you use daily), log in with your OpenAI/Codex account.

5. **After login**, the browser will redirect to something like  
   `http://localhost:1455/auth/callback?code=...&state=...`  
   (The page may not load; that’s fine.) **Copy the full URL** from the address bar.

6. **Paste it back** into the SSH terminal where the CLI is waiting and press Enter. It will exchange the code for tokens and save them. Then restart the gateway:
   ```bash
   sudo docker restart openclaw-gateway
   ```

You only need to do this once per provider; tokens are stored in `~/.openclaw/agents/main/agent/auth-profiles.json` (and related credentials).

---

## Telegram (and other channel) pairing approve

When someone DMs the bot and gets "access not configured" with a **pairing code**, approve it on the VM:

```bash
sudo docker run --rm --network host -v /home/rikinshah787/.openclaw:/home/node/.openclaw ghcr.io/phioranex/openclaw-docker:latest pairing approve telegram 74VHMVEE
```

Replace `74VHMVEE` with the code the user received. To list pending pairings first:

```bash
sudo docker run --rm --network host -v /home/rikinshah787/.openclaw:/home/node/.openclaw ghcr.io/phioranex/openclaw-docker:latest pairing list telegram
```

--- 

If you want `gcloud` available in every new PowerShell window without setting `$env:Path`, the installer or the script may add it to your user PATH. You can also add it manually in **Settings → System → About → Advanced system settings → Environment variables** by appending:

`C:\Users\rikin\AppData\Local\Google\Cloud SDK\google-cloud-sdk\bin`

to your user **Path** variable.
