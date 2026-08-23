#!/usr/bin/env bash
set -euo pipefail

sudo nginx -t
sudo systemctl status nginx --no-pager
