#!/usr/bin/env bash
set -euo pipefail

if (($#)); then
    LOG_FILES=("$@")
else
    shopt -s nullglob
    LOG_FILES=(/var/log/nginx/*access.log)
fi

if ((${#LOG_FILES[@]} == 0)); then
    echo "No nginx access logs found." >&2
    exit 1
fi

echo "Top IPs:"
awk '{print $1}' "${LOG_FILES[@]}" | sort | uniq -c | sort -nr | head

echo
echo "Common probes:"
grep -Eh "wp-login|xmlrpc|\.git|\.env|wp-json|wp-config|phpinfo|vendor/" "${LOG_FILES[@]}" || true
