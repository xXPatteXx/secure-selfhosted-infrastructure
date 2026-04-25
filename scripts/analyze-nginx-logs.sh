#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-/var/log/nginx/access.log}"

echo "Top IPs:"
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head

echo
echo "Common probes:"
grep -E "wp-login|xmlrpc|\.git|\.env|wp-json|wp-config" "$LOG_FILE" || true
