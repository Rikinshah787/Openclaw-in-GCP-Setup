@echo off
REM Run gcp-ssh.ps1 with execution policy bypass (no admin / policy change needed)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0gcp-ssh.ps1" %*
