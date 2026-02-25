#!/usr/bin/env python3
"""Add controlUi.allowedOrigins to OpenClaw config. Preserves all existing keys including auth."""
import json
import sys

path = "/home/rikinshah787/.openclaw/openclaw.json"
with open(path) as f:
    c = json.load(f)
if "gateway" not in c:
    c["gateway"] = {}
c["gateway"]["controlUi"] = {
    "allowedOrigins": [
        "https://open-claw.tail360a8f.ts.net",
        "https://open-claw.tail360a8f.ts.net:443",
        "http://100.91.159.89:18789",
        "http://100.91.159.89:18790",
        "http://35.223.143.19:18789",
        "http://35.223.143.19:18790",
    ]
}
with open(path, "w") as f:
    json.dump(c, f, indent=2)
print("OK")
sys.exit(0)
