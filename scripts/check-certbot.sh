#!/usr/bin/env bash
set -euo pipefail

systemctl status certbot.timer --no-pager
sudo certbot renew --dry-run
