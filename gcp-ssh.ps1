# GCP SSH helper - run this in PowerShell to auth and connect to your VM
# Usage: .\gcp-ssh.ps1 [instance-name] [zone] [project-id]
# Or run without args: auth, list VMs, then prompt for SSH.

$ErrorActionPreference = "Stop"
$gcloudBin = "$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin"
if (-not (Test-Path "$gcloudBin\gcloud.cmd")) {
    Write-Host "Google Cloud SDK not found at $gcloudBin" -ForegroundColor Red
    exit 1
}
$env:Path = "$gcloudBin;$env:Path"

# Ensure logged in
$accts = & gcloud.cmd auth list --format="value(account)" 2>$null | Where-Object { $_ -match '\S' }
if (-not $accts) {
    Write-Host "`n=== Sign in to Google Cloud (browser will open) ===" -ForegroundColor Cyan
    & gcloud.cmd auth login
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

# Optional: set project if provided
$project = $args[2]
if ($project) {
    & gcloud.cmd config set project $project 2>$null
}

# List instances
Write-Host "`n=== Your GCP VM instances ===" -ForegroundColor Cyan
& gcloud.cmd compute instances list --format="table(name,zone.basename(),status,networkInterfaces[0].accessConfigs[0].natIP:label=EXTERNAL_IP)"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Could not list instances. Set project: gcloud config set project YOUR_PROJECT_ID" -ForegroundColor Yellow
    exit 1
}

$instance = $args[0]
$zone = $args[1]

if ($instance -and $zone) {
    $proj = if ($project) { $project } else { (& gcloud.cmd config get-value project 2>$null) }
    Write-Host "`n=== Connecting to $instance in $zone ===" -ForegroundColor Green
    & gcloud.cmd compute ssh $instance --zone=$zone $(if ($proj) { "--project=$proj" })
} else {
    Write-Host "`nTo SSH, run:" -ForegroundColor Yellow
    Write-Host "  .\gcp-ssh.ps1 INSTANCE_NAME ZONE [PROJECT_ID]" -ForegroundColor White
    Write-Host "Example:" -ForegroundColor Yellow
    Write-Host "  .\gcp-ssh.ps1 my-vm us-central1-a my-project-id" -ForegroundColor White
}
